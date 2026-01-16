# Public IP for Application Gateway
resource "azurerm_public_ip" "gateway" {
  name                = "pip-appgw-${var.environment}-${var.resource_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = "appgw-${var.project_name}-${var.environment}-${var.resource_suffix}"
  zones               = var.enable_zone_redundancy ? ["1", "2", "3"] : null

  tags = var.tags
}

# Application Gateway
resource "azurerm_application_gateway" "main" {
  name                = "appgw-${var.project_name}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  zones               = var.enable_zone_redundancy ? ["1", "2", "3"] : null

  # SKU Configuration
  sku {
    name     = var.enable_waf ? "WAF_v2" : "Standard_v2"
    tier     = var.enable_waf ? "WAF_v2" : "Standard_v2"
    capacity = var.autoscale_min_capacity != null ? null : var.capacity
  }

  # Autoscale Configuration
  dynamic "autoscale_configuration" {
    for_each = var.autoscale_min_capacity != null ? [1] : []
    content {
      min_capacity = var.autoscale_min_capacity
      max_capacity = var.autoscale_max_capacity
    }
  }

  # Gateway IP Configuration
  gateway_ip_configuration {
    name      = "gateway-ip-config"
    subnet_id = var.subnet_id
  }

  # Frontend Port (HTTP)
  frontend_port {
    name = "http-port"
    port = 80
  }

  # Frontend Port (HTTPS)
  frontend_port {
    name = "https-port"
    port = 443
  }

  # Frontend IP Configuration
  frontend_ip_configuration {
    name                 = "public-frontend-ip"
    public_ip_address_id = azurerm_public_ip.gateway.id
  }

  # Backend Address Pools (one per agent)
  dynamic "backend_address_pool" {
    for_each = var.backend_address_pools
    content {
      name         = backend_address_pool.value.name
      ip_addresses = backend_address_pool.value.ip_addresses
      fqdns        = backend_address_pool.value.fqdns
    }
  }

  # Default Backend Address Pool (for routing)
  backend_address_pool {
    name = "default-backend-pool"
  }

  # Backend HTTP Settings
  backend_http_settings {
    name                  = "backend-http-settings"
    cookie_based_affinity = "Enabled"
    port                  = 8080
    protocol              = "Http"
    request_timeout       = 60
    probe_name            = "health-probe"

    connection_draining {
      enabled           = true
      drain_timeout_sec = 60
    }
  }

  # Health Probe
  probe {
    name                                      = "health-probe"
    protocol                                  = "Http"
    path                                      = "/health"
    interval                                  = 30
    timeout                                   = 30
    unhealthy_threshold                       = 3
    pick_host_name_from_backend_http_settings = false
    host                                      = "127.0.0.1"
    match {
      status_code = ["200-399"]
    }
  }

  # HTTP Listener
  http_listener {
    name                           = "http-listener"
    frontend_ip_configuration_name = "public-frontend-ip"
    frontend_port_name             = "http-port"
    protocol                       = "Http"
  }

  # Request Routing Rule
  request_routing_rule {
    name                       = "default-routing-rule"
    rule_type                  = "Basic"
    http_listener_name         = "http-listener"
    backend_address_pool_name  = "default-backend-pool"
    backend_http_settings_name = "backend-http-settings"
    priority                   = 100
  }

  # WAF Configuration
  dynamic "waf_configuration" {
    for_each = var.enable_waf ? [1] : []
    content {
      enabled          = true
      firewall_mode    = var.waf_mode
      rule_set_type    = "OWASP"
      rule_set_version = "3.2"

      disabled_rule_group {
        rule_group_name = "REQUEST-920-PROTOCOL-ENFORCEMENT"
        rules           = []
      }

      file_upload_limit_mb     = 100
      request_body_check       = true
      max_request_body_size_kb = 128
    }
  }

  # SSL Policy
  ssl_policy {
    policy_type = var.ssl_policy_type
    policy_name = var.ssl_policy_name
  }

  # Enable HTTP2
  enable_http2 = var.enable_http2

  # Identity for Key Vault access
  identity {
    type         = "UserAssigned"
    identity_ids = var.user_assigned_identity_ids
  }

  tags = var.tags
}

# Diagnostic Settings for Application Gateway
resource "azurerm_monitor_diagnostic_setting" "gateway" {
  count                      = var.log_analytics_workspace_id != null ? 1 : 0
  name                       = "diag-appgw-${var.environment}"
  target_resource_id         = azurerm_application_gateway.main.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "ApplicationGatewayAccessLog"
  }

  enabled_log {
    category = "ApplicationGatewayPerformanceLog"
  }

  enabled_log {
    category = "ApplicationGatewayFirewallLog"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

# Web Application Firewall Policy (for advanced WAF configuration)
resource "azurerm_web_application_firewall_policy" "main" {
  count               = var.enable_waf ? 1 : 0
  name                = "wafpolicy-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name

  policy_settings {
    enabled                     = true
    mode                        = var.waf_mode
    request_body_check          = true
    file_upload_limit_in_mb     = 100
    max_request_body_size_in_kb = 128
  }

  managed_rules {
    managed_rule_set {
      type    = "OWASP"
      version = "3.2"
    }

    managed_rule_set {
      type    = "Microsoft_BotManagerRuleSet"
      version = "1.0"
    }
  }

  custom_rules {
    name      = "RateLimitRule"
    priority  = 1
    rule_type = "RateLimitRule"

    match_conditions {
      match_variables {
        variable_name = "RemoteAddr"
      }

      operator           = "IPMatch"
      negation_condition = false
      match_values       = ["0.0.0.0/0"]
    }

    action = "Block"
    rate_limit_duration = "OneMin"
    rate_limit_threshold = 100
  }

  tags = var.tags
}
