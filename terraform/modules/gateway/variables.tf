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
  description = "Subnet ID for Application Gateway"
  type        = string
}

variable "backend_address_pools" {
  description = "Backend address pool configuration"
  type = list(object({
    name         = string
    ip_addresses = list(string)
    fqdns        = list(string)
  }))
}

variable "capacity" {
  description = "Fixed capacity for Application Gateway (if not using autoscale)"
  type        = number
  default     = 2
}

variable "autoscale_min_capacity" {
  description = "Minimum autoscale capacity"
  type        = number
  default     = 2
}

variable "autoscale_max_capacity" {
  description = "Maximum autoscale capacity"
  type        = number
  default     = 10
}

variable "enable_zone_redundancy" {
  description = "Enable zone redundancy for Application Gateway"
  type        = bool
  default     = false
}

variable "enable_waf" {
  description = "Enable Web Application Firewall"
  type        = bool
  default     = true
}

variable "waf_mode" {
  description = "WAF mode (Detection or Prevention)"
  type        = string
  default     = "Prevention"
}

variable "enable_http2" {
  description = "Enable HTTP/2 support"
  type        = bool
  default     = true
}

variable "ssl_policy_type" {
  description = "SSL policy type"
  type        = string
  default     = "Predefined"
}

variable "ssl_policy_name" {
  description = "SSL policy name"
  type        = string
  default     = "AppGwSslPolicy20220101"
}

variable "user_assigned_identity_ids" {
  description = "User-assigned managed identity IDs for Key Vault access"
  type        = list(string)
  default     = []
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
