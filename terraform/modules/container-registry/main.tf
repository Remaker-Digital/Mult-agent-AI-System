# Azure Container Registry
resource "azurerm_container_registry" "main" {
  name                = "acr${var.project_name}${var.environment}${var.resource_suffix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
  admin_enabled       = false

  # Network rules
  public_network_access_enabled = false
  network_rule_bypass_option    = "AzureServices"

  # Identity for encryption
  identity {
    type = "SystemAssigned"
  }

  # Enable encryption (Premium only)
  dynamic "encryption" {
    for_each = var.sku == "Premium" ? [1] : []
    content {
      enabled = true
    }
  }

  # Geo-replication (Premium only)
  dynamic "georeplications" {
    for_each = var.sku == "Premium" ? var.geo_replication_locations : []
    content {
      location                = georeplications.value
      zone_redundancy_enabled = true
      tags                    = var.tags
    }
  }

  # Retention policy
  retention_policy {
    days    = var.retention_days
    enabled = true
  }

  # Trust policy
  trust_policy {
    enabled = var.enable_content_trust
  }

  tags = var.tags
}

# Private Endpoint for ACR
resource "azurerm_private_endpoint" "acr" {
  name                = "pe-acr-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "psc-acr-${var.environment}"
    private_connection_resource_id = azurerm_container_registry.main.id
    is_manual_connection           = false
    subresource_names              = ["registry"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.private_dns_zone_id]
  }

  tags = var.tags
}

# Diagnostic Settings for ACR
resource "azurerm_monitor_diagnostic_setting" "acr" {
  count                      = var.log_analytics_workspace_id != null ? 1 : 0
  name                       = "diag-acr-${var.environment}"
  target_resource_id         = azurerm_container_registry.main.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "ContainerRegistryRepositoryEvents"
  }

  enabled_log {
    category = "ContainerRegistryLoginEvents"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

# Scope Map for limited access (if needed for CI/CD)
resource "azurerm_container_registry_scope_map" "ci_cd" {
  count                   = var.enable_cicd_scope_map ? 1 : 0
  name                    = "cicd-scope-map"
  container_registry_name = azurerm_container_registry.main.name
  resource_group_name     = var.resource_group_name

  actions = [
    "repositories/*/content/read",
    "repositories/*/content/write",
    "repositories/*/metadata/read",
    "repositories/*/metadata/write"
  ]
}
