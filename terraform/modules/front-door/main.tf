# Azure Front Door for Global Load Balancing
# Provides global distribution across APAC, EMEA, and Americas regions

# Front Door Profile (Standard or Premium)
resource "azurerm_cdn_frontdoor_profile" "main" {
  name                = "fd-${var.project_name}-${var.environment}"
  resource_group_name = var.resource_group_name
  sku_name            = var.frontdoor_sku_name

  response_timeout_seconds = var.response_timeout_seconds

  tags = merge(var.tags, {
    Component = "Global Load Balancer"
  })
}

# Front Door Endpoint
resource "azurerm_cdn_frontdoor_endpoint" "main" {
  name                     = "fde-${var.project_name}-${var.environment}"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main.id

  tags = var.tags
}

# Origin Group for Application Gateway (regional backends)
resource "azurerm_cdn_frontdoor_origin_group" "gateway" {
  name                     = "og-gateway-${var.environment}"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main.id

  load_balancing {
    sample_size                        = var.load_balancing_sample_size
    successful_samples_required        = var.load_balancing_successful_samples
    additional_latency_in_milliseconds = var.load_balancing_additional_latency
  }

  health_probe {
    protocol            = "Http"
    path                = var.health_probe_path
    request_type        = "GET"
    interval_in_seconds = var.health_probe_interval
  }

  session_affinity_enabled = var.session_affinity_enabled
}

# Primary Origin (Application Gateway in primary region)
resource "azurerm_cdn_frontdoor_origin" "primary" {
  name                          = "origin-primary-${var.environment}"
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.gateway.id
  enabled                       = true

  certificate_name_check_enabled = true
  host_name                      = var.primary_backend_hostname
  http_port                      = 80
  https_port                     = 443
  origin_host_header             = var.primary_backend_hostname
  priority                       = 1
  weight                         = 1000
}

# Secondary Origins for Regional Deployments (APAC, EMEA)
resource "azurerm_cdn_frontdoor_origin" "secondary" {
  for_each = var.regional_backends

  name                          = "origin-${each.key}-${var.environment}"
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.gateway.id
  enabled                       = true

  certificate_name_check_enabled = true
  host_name                      = each.value.hostname
  http_port                      = 80
  https_port                     = 443
  origin_host_header             = each.value.hostname
  priority                       = each.value.priority
  weight                         = each.value.weight
}

# Front Door Route (routing configuration)
resource "azurerm_cdn_frontdoor_route" "main" {
  name                          = "route-default-${var.environment}"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.main.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.gateway.id
  cdn_frontdoor_origin_ids      = concat(
    [azurerm_cdn_frontdoor_origin.primary.id],
    [for origin in azurerm_cdn_frontdoor_origin.secondary : origin.id]
  )

  supported_protocols    = ["Http", "Https"]
  patterns_to_match      = ["/*"]
  forwarding_protocol    = "HttpsOnly"
  https_redirect_enabled = true

  cdn_frontdoor_custom_domain_ids = var.custom_domain_ids
  link_to_default_domain          = true

  # Caching configuration
  cache {
    query_string_caching_behavior = var.cache_query_string_behavior
    compression_enabled           = var.cache_compression_enabled
    content_types_to_compress     = var.cache_content_types_to_compress
  }
}

# WAF Policy for Front Door
resource "azurerm_cdn_frontdoor_firewall_policy" "main" {
  count               = var.enable_waf ? 1 : 0
  name                = "fdwaf${var.project_name}${var.environment}"
  resource_group_name = var.resource_group_name
  sku_name            = var.frontdoor_sku_name
  enabled             = true
  mode                = var.waf_mode

  # Custom rules for rate limiting and geo-filtering
  custom_rule {
    name                           = "RateLimitPerIP"
    enabled                        = true
    priority                       = 1
    rate_limit_duration_in_minutes = 1
    rate_limit_threshold           = var.rate_limit_threshold
    type                           = "RateLimitRule"
    action                         = "Block"

    match_condition {
      match_variable     = "RemoteAddr"
      operator           = "IPMatch"
      negation_condition = false
      match_values       = ["0.0.0.0/0"]
    }
  }

  # Geo-filtering (optional - allow specific regions)
  dynamic "custom_rule" {
    for_each = var.allowed_geo_locations != null ? [1] : []
    content {
      name                           = "GeoFiltering"
      enabled                        = true
      priority                       = 2
      rate_limit_duration_in_minutes = 1
      rate_limit_threshold           = 0
      type                           = "MatchRule"
      action                         = "Block"

      match_condition {
        match_variable     = "RemoteAddr"
        operator           = "GeoMatch"
        negation_condition = true
        match_values       = var.allowed_geo_locations
      }
    }
  }

  # Managed rule sets
  managed_rule {
    type    = "Microsoft_DefaultRuleSet"
    version = "2.1"
    action  = "Block"

    # Override specific rules if needed
    dynamic "override" {
      for_each = var.waf_rule_overrides
      content {
        rule_group_name = override.value.rule_group_name

        dynamic "rule" {
          for_each = override.value.rules
          content {
            rule_id = rule.value.rule_id
            enabled = rule.value.enabled
            action  = rule.value.action
          }
        }
      }
    }
  }

  managed_rule {
    type    = "Microsoft_BotManagerRuleSet"
    version = "1.0"
    action  = "Block"
  }

  tags = var.tags
}

# Security Policy (associates WAF with endpoint)
resource "azurerm_cdn_frontdoor_security_policy" "main" {
  count                    = var.enable_waf ? 1 : 0
  name                     = "security-policy-${var.environment}"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main.id

  security_policies {
    firewall {
      cdn_frontdoor_firewall_policy_id = azurerm_cdn_frontdoor_firewall_policy.main[0].id

      association {
        domain {
          cdn_frontdoor_domain_id = azurerm_cdn_frontdoor_endpoint.main.id
        }
        patterns_to_match = ["/*"]
      }
    }
  }
}

# Diagnostic Settings for Front Door
resource "azurerm_monitor_diagnostic_setting" "frontdoor" {
  count                      = var.log_analytics_workspace_id != null ? 1 : 0
  name                       = "diag-fd-${var.environment}"
  target_resource_id         = azurerm_cdn_frontdoor_profile.main.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "FrontDoorAccessLog"
  }

  enabled_log {
    category = "FrontDoorHealthProbeLog"
  }

  enabled_log {
    category = "FrontDoorWebApplicationFirewallLog"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
