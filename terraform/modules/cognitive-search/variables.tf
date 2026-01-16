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
  description = "Random suffix for globally unique names"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

# Search Service Configuration
variable "search_sku" {
  description = "SKU for Azure Cognitive Search (free, basic, standard, standard2, standard3, storage_optimized_l1, storage_optimized_l2)"
  type        = string
  default     = "standard"

  validation {
    condition     = contains(["free", "basic", "standard", "standard2", "standard3", "storage_optimized_l1", "storage_optimized_l2"], var.search_sku)
    error_message = "Invalid search SKU."
  }
}

variable "replica_count" {
  description = "Number of replicas (for high availability)"
  type        = number
  default     = 1

  validation {
    condition     = var.replica_count >= 1 && var.replica_count <= 12
    error_message = "Replica count must be between 1 and 12."
  }
}

variable "partition_count" {
  description = "Number of partitions (for scale)"
  type        = number
  default     = 1

  validation {
    condition     = contains([1, 2, 3, 4, 6, 12], var.partition_count)
    error_message = "Partition count must be 1, 2, 3, 4, 6, or 12."
  }
}

# Feature Flags
variable "enable_semantic_search" {
  description = "Enable semantic search for better relevance (requires standard or higher SKU)"
  type        = bool
  default     = true
}

variable "public_network_access_enabled" {
  description = "Enable public network access to the search service"
  type        = bool
  default     = false
}

variable "local_authentication_enabled" {
  description = "Enable local authentication (API keys)"
  type        = bool
  default     = true
}

variable "customer_managed_key_enabled" {
  description = "Enable customer-managed encryption keys"
  type        = bool
  default     = false
}

# Private Endpoint Configuration
variable "enable_private_endpoint" {
  description = "Enable private endpoint for secure access"
  type        = bool
  default     = true
}

variable "subnet_id" {
  description = "Subnet ID for private endpoint"
  type        = string
  default     = null
}

variable "private_dns_zone_id" {
  description = "Private DNS zone ID for search service"
  type        = string
  default     = null
}

# Key Vault Integration
variable "key_vault_id" {
  description = "Key Vault ID for storing search keys"
  type        = string
}

# RBAC Configuration
variable "storage_account_id" {
  description = "Storage Account ID for search indexers (optional)"
  type        = string
  default     = null
}

variable "cosmos_db_account_id" {
  description = "Cosmos DB Account ID for search indexers (optional)"
  type        = string
  default     = null
}

variable "knowledge_agent_identity_principal_id" {
  description = "Principal ID of the knowledge agent's managed identity"
  type        = string
  default     = null
}

# Observability
variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for diagnostics"
  type        = string
  default     = null
}

variable "enable_alerts" {
  description = "Enable metric alerts for search service"
  type        = bool
  default     = true
}

variable "action_group_id" {
  description = "Action group ID for alerts"
  type        = string
  default     = null
}

variable "search_latency_threshold_ms" {
  description = "Threshold for search latency alert (milliseconds)"
  type        = number
  default     = 1000

  validation {
    condition     = var.search_latency_threshold_ms > 0
    error_message = "Search latency threshold must be greater than 0."
  }
}
