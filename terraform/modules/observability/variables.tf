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

variable "log_retention_days" {
  description = "Log retention period in days"
  type        = number
  default     = 30
}

variable "daily_quota_gb" {
  description = "Daily ingestion quota in GB for Log Analytics"
  type        = number
  default     = -1 # Unlimited
}

variable "app_insights_retention_days" {
  description = "Application Insights retention period in days"
  type        = number
  default     = 90
}

variable "app_insights_daily_cap_gb" {
  description = "Daily ingestion cap in GB for Application Insights"
  type        = number
  default     = 10
}

variable "alert_email_addresses" {
  description = "Email addresses for alert notifications"
  type        = list(string)
  default     = []
}

variable "monthly_budget_amount" {
  description = "Monthly budget amount in USD"
  type        = number
  default     = 5000
}

variable "budget_alert_thresholds" {
  description = "Budget alert thresholds (percentages)"
  type        = list(number)
  default     = [80, 95]
}

variable "enable_custom_metrics" {
  description = "Enable custom metrics for agent performance"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}
