# Cosmos DB Account
resource "azurerm_cosmosdb_account" "main" {
  name                = "cosmos-${var.project_name}-${var.environment}-${var.resource_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  # Consistency policy
  consistency_policy {
    consistency_level       = var.cosmos_db_consistency_level
    max_interval_in_seconds = var.cosmos_db_max_interval_in_seconds
    max_staleness_prefix    = var.cosmos_db_max_staleness_prefix
  }

  # Geo-location
  geo_location {
    location          = var.location
    failover_priority = 0
    zone_redundant    = var.environment == "production" ? true : false
  }

  # Capabilities
  capabilities {
    name = "EnableServerless"
  }

  # Network settings
  public_network_access_enabled     = false
  is_virtual_network_filter_enabled = true
  network_acl_bypass_for_azure_services = true

  # Backup
  backup {
    type                = var.cosmos_db_backup_type
    interval_in_minutes = var.cosmos_db_backup_interval
    retention_in_hours  = var.cosmos_db_backup_retention
    storage_redundancy  = var.cosmos_db_backup_redundancy
  }

  # Identity
  identity {
    type = "SystemAssigned"
  }

  # Automatic failover
  automatic_failover_enabled = var.environment == "production" ? true : false

  tags = var.tags
}

# Cosmos DB SQL Databases
resource "azurerm_cosmosdb_sql_database" "databases" {
  for_each            = var.cosmos_db_databases
  name                = each.key
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.main.name
}

# Cosmos DB SQL Containers
resource "azurerm_cosmosdb_sql_container" "containers" {
  for_each = merge([
    for db_name, db_config in var.cosmos_db_databases : {
      for container_name, container_config in db_config.containers :
      "${db_name}-${container_name}" => merge(container_config, {
        database_name  = db_name
        container_name = container_name
      })
    }
  ]...)

  name                  = each.value.container_name
  resource_group_name   = var.resource_group_name
  account_name          = azurerm_cosmosdb_account.main.name
  database_name         = azurerm_cosmosdb_sql_database.databases[each.value.database_name].name
  partition_key_path    = each.value.partition_key_path
  partition_key_version = 2

  autoscale_settings {
    max_throughput = each.value.autoscale_settings.max_throughput
  }

  indexing_policy {
    indexing_mode = "consistent"

    included_path {
      path = "/*"
    }

    excluded_path {
      path = "/\"_etag\"/?"
    }
  }

  default_ttl = -1
}

# Private Endpoint for Cosmos DB
resource "azurerm_private_endpoint" "cosmos" {
  name                = "pe-cosmos-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "psc-cosmos-${var.environment}"
    private_connection_resource_id = azurerm_cosmosdb_account.main.id
    is_manual_connection           = false
    subresource_names              = ["Sql"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.cosmos_private_dns_zone_id]
  }

  tags = var.tags
}

# Store Cosmos DB key in Key Vault
resource "azurerm_key_vault_secret" "cosmos_primary_key" {
  name         = "cosmos-primary-key"
  value        = azurerm_cosmosdb_account.main.primary_key
  key_vault_id = var.key_vault_id

  tags = var.tags
}

# Azure Cache for Redis
resource "azurerm_redis_cache" "main" {
  name                = "redis-${var.project_name}-${var.environment}-${var.resource_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  capacity            = var.redis_capacity
  family              = var.redis_family
  sku_name            = var.redis_sku_name

  # Network settings
  public_network_access_enabled = false
  minimum_tls_version           = var.redis_minimum_tls_version

  # Redis configuration
  redis_configuration {
    enable_authentication           = true
    maxmemory_reserved              = var.redis_sku_name == "Premium" ? 2 : null
    maxmemory_delta                 = var.redis_sku_name == "Premium" ? 2 : null
    maxmemory_policy                = "allkeys-lru"
    notify_keyspace_events          = ""
    rdb_backup_enabled              = var.redis_sku_name == "Premium" ? var.enable_redis_backup : null
    rdb_backup_frequency            = var.redis_sku_name == "Premium" && var.enable_redis_backup ? 60 : null
    rdb_backup_max_snapshot_count   = var.redis_sku_name == "Premium" && var.enable_redis_backup ? 1 : null
  }

  # Zone redundancy (Premium only)
  zones = var.redis_sku_name == "Premium" && var.environment == "production" ? ["1", "2", "3"] : null

  # Patch schedule
  patch_schedule {
    day_of_week    = "Sunday"
    start_hour_utc = 2
  }

  # Identity
  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

# Private Endpoint for Redis
resource "azurerm_private_endpoint" "redis" {
  name                = "pe-redis-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "psc-redis-${var.environment}"
    private_connection_resource_id = azurerm_redis_cache.main.id
    is_manual_connection           = false
    subresource_names              = ["redisCache"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.redis_private_dns_zone_id]
  }

  tags = var.tags
}

# Store Redis key in Key Vault
resource "azurerm_key_vault_secret" "redis_primary_key" {
  name         = "redis-primary-key"
  value        = azurerm_redis_cache.main.primary_access_key
  key_vault_id = var.key_vault_id

  tags = var.tags
}

# Diagnostic Settings for Cosmos DB
resource "azurerm_monitor_diagnostic_setting" "cosmos" {
  count                      = var.log_analytics_workspace_id != null ? 1 : 0
  name                       = "diag-cosmos-${var.environment}"
  target_resource_id         = azurerm_cosmosdb_account.main.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "DataPlaneRequests"
  }

  enabled_log {
    category = "QueryRuntimeStatistics"
  }

  enabled_log {
    category = "PartitionKeyStatistics"
  }

  enabled_log {
    category = "PartitionKeyRUConsumption"
  }

  enabled_log {
    category = "ControlPlaneRequests"
  }

  metric {
    category = "Requests"
    enabled  = true
  }
}

# Diagnostic Settings for Redis
resource "azurerm_monitor_diagnostic_setting" "redis" {
  count                      = var.log_analytics_workspace_id != null ? 1 : 0
  name                       = "diag-redis-${var.environment}"
  target_resource_id         = azurerm_redis_cache.main.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "ConnectedClientList"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
