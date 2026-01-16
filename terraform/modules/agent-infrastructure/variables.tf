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

variable "subnet_id" {
  description = "Subnet ID for container groups"
  type        = string
}

variable "agents" {
  description = "Configuration for AI agents"
  type = map(object({
    name        = string
    description = string
    port        = number
  }))
}

variable "agent_container_image" {
  description = "Container image for agents"
  type        = string
}

variable "agent_cpu" {
  description = "CPU cores per agent container"
  type        = number
  default     = 1
}

variable "agent_memory" {
  description = "Memory (GB) per agent container"
  type        = number
  default     = 2
}

variable "container_registry_id" {
  description = "ID of the container registry"
  type        = string
}

variable "container_registry_server" {
  description = "Login server for the container registry"
  type        = string
}

variable "user_assigned_identity_id" {
  description = "ID of the user-assigned managed identity"
  type        = string
}

variable "key_vault_id" {
  description = "ID of the Key Vault"
  type        = string
}

variable "cosmos_db_endpoint" {
  description = "Cosmos DB endpoint URL"
  type        = string
}

variable "cosmos_db_key_secret_id" {
  description = "Key Vault secret ID for Cosmos DB key"
  type        = string
}

variable "redis_hostname" {
  description = "Redis hostname"
  type        = string
}

variable "redis_key_secret_id" {
  description = "Key Vault secret ID for Redis key"
  type        = string
}

variable "app_insights_instrumentation_key" {
  description = "Application Insights instrumentation key"
  type        = string
  sensitive   = true
}

variable "app_insights_connection_string" {
  description = "Application Insights connection string"
  type        = string
  sensitive   = true
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID"
  type        = string
}

variable "log_analytics_workspace_key" {
  description = "Log Analytics workspace key"
  type        = string
  sensitive   = true
}

variable "enable_autoscaling" {
  description = "Enable autoscaling for agents"
  type        = bool
  default     = true
}

variable "min_instance_count" {
  description = "Minimum number of instances per agent"
  type        = number
  default     = 2
}

variable "max_instance_count" {
  description = "Maximum number of instances per agent"
  type        = number
  default     = 10
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}
