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

variable "sku" {
  description = "SKU for Azure Container Registry"
  type        = string
  default     = "Premium"
}

variable "geo_replication_locations" {
  description = "Locations for geo-replication (Premium SKU only)"
  type        = list(string)
  default     = []
}

variable "subnet_id" {
  description = "Subnet ID for private endpoint"
  type        = string
}

variable "private_dns_zone_id" {
  description = "Private DNS zone ID for ACR"
  type        = string
  default     = null
}

variable "retention_days" {
  description = "Number of days to retain images"
  type        = number
  default     = 7
}

variable "enable_content_trust" {
  description = "Enable content trust for image signing"
  type        = bool
  default     = false
}

variable "enable_cicd_scope_map" {
  description = "Enable scope map for CI/CD pipelines"
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
