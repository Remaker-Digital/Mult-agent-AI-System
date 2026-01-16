output "cosmos_db_id" {
  description = "ID of the Cosmos DB account"
  value       = azurerm_cosmosdb_account.main.id
}

output "cosmos_db_endpoint" {
  description = "Endpoint URL for Cosmos DB"
  value       = azurerm_cosmosdb_account.main.endpoint
}

output "cosmos_db_account_name" {
  description = "Name of the Cosmos DB account"
  value       = azurerm_cosmosdb_account.main.name
}

output "cosmos_db_primary_key" {
  description = "Primary key for Cosmos DB"
  value       = azurerm_cosmosdb_account.main.primary_key
  sensitive   = true
}

output "cosmos_db_key_secret_id" {
  description = "Key Vault secret ID for Cosmos DB key"
  value       = azurerm_key_vault_secret.cosmos_primary_key.id
}

output "cosmos_db_database_names" {
  description = "Names of Cosmos DB databases"
  value       = [for db in azurerm_cosmosdb_sql_database.databases : db.name]
}

output "redis_id" {
  description = "ID of the Redis cache"
  value       = azurerm_redis_cache.main.id
}

output "redis_hostname" {
  description = "Hostname for Redis cache"
  value       = azurerm_redis_cache.main.hostname
}

output "redis_ssl_port" {
  description = "SSL port for Redis cache"
  value       = azurerm_redis_cache.main.ssl_port
}

output "redis_port" {
  description = "Non-SSL port for Redis cache"
  value       = azurerm_redis_cache.main.port
}

output "redis_name" {
  description = "Name of the Redis cache"
  value       = azurerm_redis_cache.main.name
}

output "redis_primary_access_key" {
  description = "Primary access key for Redis"
  value       = azurerm_redis_cache.main.primary_access_key
  sensitive   = true
}

output "redis_key_secret_id" {
  description = "Key Vault secret ID for Redis key"
  value       = azurerm_key_vault_secret.redis_primary_key.id
}

output "redis_connection_string" {
  description = "Connection string for Redis"
  value       = "${azurerm_redis_cache.main.hostname}:${azurerm_redis_cache.main.ssl_port},password=${azurerm_redis_cache.main.primary_access_key},ssl=True,abortConnect=False"
  sensitive   = true
}
