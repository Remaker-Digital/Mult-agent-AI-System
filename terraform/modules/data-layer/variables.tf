variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "resource_suffix" {
  description = "Random suffix for unique naming"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for private endpoints"
  type        = string
}

variable "key_vault_id" {
  description = "Key Vault ID for storing secrets"
  type        = string
}

variable "cosmos_private_dns_zone_id" {
  description = "Private DNS zone ID for Cosmos DB"
  type        = string
  default     = null
}

variable "redis_private_dns_zone_id" {
  description = "Private DNS zone ID for Redis"
  type        = string
  default     = null
}

# Cosmos DB Variables
variable "cosmos_db_consistency_level" {
  description = "Consistency level for Cosmos DB"
  type        = string
  default     = "Session"
}

variable "cosmos_db_max_interval_in_seconds" {
  description = "Max staleness interval in seconds (BoundedStaleness only)"
  type        = number
  default     = 10
}

variable "cosmos_db_max_staleness_prefix" {
  description = "Max staleness prefix (BoundedStaleness only)"
  type        = number
  default     = 200
}

variable "cosmos_db_autoscale_max_throughput" {
  description = "Maximum RU/s for Cosmos DB autoscale"
  type        = number
  default     = 4000
}

variable "cosmos_db_databases" {
  description = "Cosmos DB databases and containers configuration"
  type = map(object({
    containers = map(object({
      partition_key_path = string
      autoscale_settings = object({
        max_throughput = number
      })
    }))
  }))
}

variable "cosmos_db_backup_type" {
  description = "Backup type for Cosmos DB (Periodic or Continuous)"
  type        = string
  default     = "Periodic"
}

variable "cosmos_db_backup_interval" {
  description = "Backup interval in minutes (Periodic only)"
  type        = number
  default     = 240
}

variable "cosmos_db_backup_retention" {
  description = "Backup retention in hours (Periodic only)"
  type        = number
  default     = 8
}

variable "cosmos_db_backup_redundancy" {
  description = "Backup storage redundancy (Geo, Local, Zone)"
  type        = string
  default     = "Geo"
}

# Redis Variables
variable "redis_capacity" {
  description = "Redis cache capacity (GB)"
  type        = number
  default     = 1
}

variable "redis_family" {
  description = "Redis cache family (C for Basic/Standard, P for Premium)"
  type        = string
  default     = "C"
}

variable "redis_sku_name" {
  description = "Redis cache SKU"
  type        = string
  default     = "Standard"
}

variable "redis_enable_non_ssl_port" {
  description = "Enable non-SSL port for Redis"
  type        = bool
  default     = false
}

variable "redis_minimum_tls_version" {
  description = "Minimum TLS version for Redis"
  type        = string
  default     = "1.3"
}

variable "enable_redis_backup" {
  description = "Enable Redis backup (Premium SKU only)"
  type        = bool
  default     = false
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for diagnostics"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}
