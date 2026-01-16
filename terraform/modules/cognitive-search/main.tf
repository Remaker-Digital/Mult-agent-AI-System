# Azure Cognitive Search for Knowledge Retrieval
# Provides intelligent search capabilities for the Knowledge Agent

# Cognitive Search Service
resource "azurerm_search_service" "main" {
  name                = "search-${var.project_name}-${var.environment}-${var.resource_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.search_sku

  # Replica and partition count
  replica_count   = var.replica_count
  partition_count = var.partition_count

  # Public network access control
  public_network_access_enabled = var.public_network_access_enabled

  # Identity for accessing other Azure resources
  identity {
    type = "SystemAssigned"
  }

  # Semantic search (Premium feature for better relevance)
  semantic_search_sku = var.enable_semantic_search ? "standard" : null

  # Local authentication (API keys)
  local_authentication_enabled = var.local_authentication_enabled

  # Customer-managed encryption
  customer_managed_key_enforcement_enabled = var.customer_managed_key_enabled

  tags = merge(var.tags, {
    Component = "Knowledge Search"
    Agent     = "knowledge-agent"
  })
}

# Private Endpoint for Cognitive Search (secure access)
resource "azurerm_private_endpoint" "search" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = "pe-search-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "psc-search-${var.environment}"
    private_connection_resource_id = azurerm_search_service.main.id
    is_manual_connection           = false
    subresource_names              = ["searchService"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.private_dns_zone_id]
  }

  tags = var.tags
}

# Store Search Admin Key in Key Vault
resource "azurerm_key_vault_secret" "search_admin_key" {
  name         = "search-admin-key"
  value        = azurerm_search_service.main.primary_key
  key_vault_id = var.key_vault_id

  tags = var.tags
}

# Store Search Query Key in Key Vault
resource "azurerm_key_vault_secret" "search_query_key" {
  name         = "search-query-key"
  value        = azurerm_search_service.main.query_keys[0].key
  key_vault_id = var.key_vault_id

  tags = var.tags
}

# Store Search Endpoint in Key Vault
resource "azurerm_key_vault_secret" "search_endpoint" {
  name         = "search-endpoint"
  value        = "https://${azurerm_search_service.main.name}.search.windows.net"
  key_vault_id = var.key_vault_id

  tags = var.tags
}

# RBAC - Grant Search Service access to Storage Account (for indexers)
resource "azurerm_role_assignment" "search_to_storage" {
  count                = var.storage_account_id != null ? 1 : 0
  scope                = var.storage_account_id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azurerm_search_service.main.identity[0].principal_id
}

# RBAC - Grant Search Service access to Cosmos DB (for indexers)
resource "azurerm_role_assignment" "search_to_cosmos" {
  count                = var.cosmos_db_account_id != null ? 1 : 0
  scope                = var.cosmos_db_account_id
  role_definition_name = "Cosmos DB Account Reader Role"
  principal_id         = azurerm_search_service.main.identity[0].principal_id
}

# RBAC - Grant Knowledge Agent managed identity access to Search Service
resource "azurerm_role_assignment" "agent_to_search" {
  count                = var.knowledge_agent_identity_principal_id != null ? 1 : 0
  scope                = azurerm_search_service.main.id
  role_definition_name = "Search Index Data Contributor"
  principal_id         = var.knowledge_agent_identity_principal_id
}

# Diagnostic Settings for Cognitive Search
resource "azurerm_monitor_diagnostic_setting" "search" {
  count                      = var.log_analytics_workspace_id != null ? 1 : 0
  name                       = "diag-search-${var.environment}"
  target_resource_id         = azurerm_search_service.main.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "OperationLogs"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

# Alert for high search latency
resource "azurerm_monitor_metric_alert" "search_latency" {
  count               = var.enable_alerts ? 1 : 0
  name                = "alert-search-latency-${var.environment}"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_search_service.main.id]
  description         = "Alert when search latency exceeds threshold"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.Search/searchServices"
    metric_name      = "SearchLatency"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.search_latency_threshold_ms
  }

  action {
    action_group_id = var.action_group_id
  }

  tags = var.tags
}

# Alert for throttled search requests
resource "azurerm_monitor_metric_alert" "search_throttled" {
  count               = var.enable_alerts ? 1 : 0
  name                = "alert-search-throttled-${var.environment}"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_search_service.main.id]
  description         = "Alert when search requests are throttled"
  severity            = 1
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.Search/searchServices"
    metric_name      = "ThrottledSearchQueriesPercentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 5
  }

  action {
    action_group_id = var.action_group_id
  }

  tags = var.tags
}

# Alert for search service availability
resource "azurerm_monitor_metric_alert" "search_availability" {
  count               = var.enable_alerts ? 1 : 0
  name                = "alert-search-availability-${var.environment}"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_search_service.main.id]
  description         = "Alert when search service availability drops"
  severity            = 0
  frequency           = "PT1M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.Search/searchServices"
    metric_name      = "SearchQueriesPerSecond"
    aggregation      = "Total"
    operator         = "LessThan"
    threshold        = 1
  }

  action {
    action_group_id = var.action_group_id
  }

  tags = var.tags
}
