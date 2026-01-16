variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

# Front Door Configuration
variable "frontdoor_sku_name" {
  description = "SKU for Azure Front Door (Standard_AzureFrontDoor or Premium_AzureFrontDoor)"
  type        = string
  default     = "Standard_AzureFrontDoor"

  validation {
    condition     = contains(["Standard_AzureFrontDoor", "Premium_AzureFrontDoor"], var.frontdoor_sku_name)
    error_message = "Front Door SKU must be Standard_AzureFrontDoor or Premium_AzureFrontDoor."
  }
}

variable "response_timeout_seconds" {
  description = "Response timeout in seconds"
  type        = number
  default     = 120

  validation {
    condition     = var.response_timeout_seconds >= 16 && var.response_timeout_seconds <= 240
    error_message = "Response timeout must be between 16 and 240 seconds."
  }
}

# Backend Configuration
variable "primary_backend_hostname" {
  description = "Hostname of the primary backend (Application Gateway)"
  type        = string
}

variable "regional_backends" {
  description = "Map of regional backend configurations for global distribution"
  type = map(object({
    hostname = string
    priority = number
    weight   = number
  }))
  default = {}
}

variable "custom_domain_ids" {
  description = "List of custom domain IDs to associate with the route"
  type        = list(string)
  default     = []
}

# Load Balancing Configuration
variable "load_balancing_sample_size" {
  description = "Number of samples to consider for load balancing decision"
  type        = number
  default     = 4
}

variable "load_balancing_successful_samples" {
  description = "Number of samples within sample period that must succeed"
  type        = number
  default     = 3
}

variable "load_balancing_additional_latency" {
  description = "Additional latency in milliseconds for load balancing"
  type        = number
  default     = 50
}

# Health Probe Configuration
variable "health_probe_path" {
  description = "Path for health probe"
  type        = string
  default     = "/health"
}

variable "health_probe_interval" {
  description = "Health probe interval in seconds"
  type        = number
  default     = 30

  validation {
    condition     = contains([5, 30, 60, 120, 240], var.health_probe_interval)
    error_message = "Health probe interval must be 5, 30, 60, 120, or 240 seconds."
  }
}

# Session Configuration
variable "session_affinity_enabled" {
  description = "Enable session affinity (sticky sessions)"
  type        = bool
  default     = true
}

# Caching Configuration
variable "cache_query_string_behavior" {
  description = "Query string caching behavior"
  type        = string
  default     = "IgnoreQueryString"

  validation {
    condition     = contains(["IgnoreQueryString", "UseQueryString", "IgnoreSpecifiedQueryStrings", "IncludeSpecifiedQueryStrings"], var.cache_query_string_behavior)
    error_message = "Invalid query string caching behavior."
  }
}

variable "cache_compression_enabled" {
  description = "Enable compression for cached content"
  type        = bool
  default     = true
}

variable "cache_content_types_to_compress" {
  description = "Content types to compress"
  type        = list(string)
  default = [
    "application/eot",
    "application/font",
    "application/font-sfnt",
    "application/javascript",
    "application/json",
    "application/opentype",
    "application/otf",
    "application/pkcs7-mime",
    "application/truetype",
    "application/ttf",
    "application/vnd.ms-fontobject",
    "application/xhtml+xml",
    "application/xml",
    "application/xml+rss",
    "application/x-font-opentype",
    "application/x-font-truetype",
    "application/x-font-ttf",
    "application/x-httpd-cgi",
    "application/x-javascript",
    "application/x-mpegurl",
    "application/x-opentype",
    "application/x-otf",
    "application/x-perl",
    "application/x-ttf",
    "font/eot",
    "font/ttf",
    "font/otf",
    "font/opentype",
    "image/svg+xml",
    "text/css",
    "text/csv",
    "text/html",
    "text/javascript",
    "text/js",
    "text/plain",
    "text/richtext",
    "text/tab-separated-values",
    "text/xml",
    "text/x-script",
    "text/x-component",
    "text/x-java-source"
  ]
}

# WAF Configuration
variable "enable_waf" {
  description = "Enable Web Application Firewall"
  type        = bool
  default     = true
}

variable "waf_mode" {
  description = "WAF mode (Detection or Prevention)"
  type        = string
  default     = "Prevention"

  validation {
    condition     = contains(["Detection", "Prevention"], var.waf_mode)
    error_message = "WAF mode must be Detection or Prevention."
  }
}

variable "rate_limit_threshold" {
  description = "Number of requests per IP per minute before rate limiting"
  type        = number
  default     = 100

  validation {
    condition     = var.rate_limit_threshold >= 0 && var.rate_limit_threshold <= 100000
    error_message = "Rate limit threshold must be between 0 and 100,000."
  }
}

variable "allowed_geo_locations" {
  description = "List of allowed country codes for geo-filtering (null to disable)"
  type        = list(string)
  default     = null
}

variable "waf_rule_overrides" {
  description = "WAF managed rule overrides"
  type = list(object({
    rule_group_name = string
    rules = list(object({
      rule_id = string
      enabled = bool
      action  = string
    }))
  }))
  default = []
}

# Observability
variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for diagnostics"
  type        = string
  default     = null
}
