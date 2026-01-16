# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "main" {
  name                = "log-${var.project_name}-${var.environment}-${var.resource_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_retention_days

  daily_quota_gb = var.daily_quota_gb

  tags = var.tags
}

# Application Insights
resource "azurerm_application_insights" "main" {
  name                = "appi-${var.project_name}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  workspace_id        = azurerm_log_analytics_workspace.main.id
  application_type    = "web"

  retention_in_days = var.app_insights_retention_days

  daily_data_cap_in_gb                  = var.app_insights_daily_cap_gb
  daily_data_cap_notifications_disabled = false

  sampling_percentage = var.environment == "production" ? 100 : 50

  tags = var.tags
}

# Action Group for Alerts
resource "azurerm_monitor_action_group" "main" {
  name                = "ag-${var.project_name}-${var.environment}"
  resource_group_name = var.resource_group_name
  short_name          = substr("${var.project_name}-${var.environment}", 0, 12)

  dynamic "email_receiver" {
    for_each = var.alert_email_addresses
    content {
      name                    = "email-${email_receiver.key}"
      email_address           = email_receiver.value
      use_common_alert_schema = true
    }
  }

  tags = var.tags
}

# Budget Alert
resource "azurerm_consumption_budget_subscription" "main" {
  name            = "budget-${var.project_name}-${var.environment}"
  subscription_id = data.azurerm_client_config.current.subscription_id

  amount     = var.monthly_budget_amount
  time_grain = "Monthly"

  time_period {
    start_date = formatdate("YYYY-MM-01'T'00:00:00Z", timestamp())
  }

  notification {
    enabled        = true
    threshold      = var.budget_alert_thresholds[0]
    operator       = "GreaterThan"
    threshold_type = "Actual"

    contact_emails = var.alert_email_addresses
  }

  notification {
    enabled        = true
    threshold      = var.budget_alert_thresholds[1]
    operator       = "GreaterThan"
    threshold_type = "Actual"

    contact_emails = var.alert_email_addresses
  }

  notification {
    enabled        = true
    threshold      = 100
    operator       = "GreaterThan"
    threshold_type = "Forecasted"

    contact_emails = var.alert_email_addresses
  }
}

# Metric Alert: High CPU Usage
resource "azurerm_monitor_metric_alert" "high_cpu" {
  count               = var.enable_custom_metrics ? 1 : 0
  name                = "alert-high-cpu-${var.environment}"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_log_analytics_workspace.main.id]
  description         = "Alert when CPU usage is consistently high"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.Insights/components"
    metric_name      = "performanceCounters/processCpuPercentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }

  tags = var.tags
}

# Metric Alert: High Memory Usage
resource "azurerm_monitor_metric_alert" "high_memory" {
  count               = var.enable_custom_metrics ? 1 : 0
  name                = "alert-high-memory-${var.environment}"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_log_analytics_workspace.main.id]
  description         = "Alert when memory usage is consistently high"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.Insights/components"
    metric_name      = "performanceCounters/memoryAvailableBytes"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 536870912 # 512 MB
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }

  tags = var.tags
}

# Metric Alert: High Error Rate
resource "azurerm_monitor_metric_alert" "high_error_rate" {
  count               = var.enable_custom_metrics ? 1 : 0
  name                = "alert-high-error-rate-${var.environment}"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_application_insights.main.id]
  description         = "Alert when error rate exceeds threshold"
  severity            = 1
  frequency           = "PT1M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.Insights/components"
    metric_name      = "exceptions/server"
    aggregation      = "Count"
    operator         = "GreaterThan"
    threshold        = 10
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }

  tags = var.tags
}

# Metric Alert: High Response Time
resource "azurerm_monitor_metric_alert" "high_response_time" {
  count               = var.enable_custom_metrics ? 1 : 0
  name                = "alert-high-response-time-${var.environment}"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_application_insights.main.id]
  description         = "Alert when response time is consistently high"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.Insights/components"
    metric_name      = "requests/duration"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 1000 # 1 second in milliseconds
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }

  tags = var.tags
}

# Metric Alert: Low Availability
resource "azurerm_monitor_metric_alert" "low_availability" {
  count               = var.enable_custom_metrics ? 1 : 0
  name                = "alert-low-availability-${var.environment}"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_application_insights.main.id]
  description         = "Alert when availability drops below threshold"
  severity            = 0
  frequency           = "PT1M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.Insights/components"
    metric_name      = "availabilityResults/availabilityPercentage"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 99
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }

  tags = var.tags
}

# Data source for current Azure configuration
data "azurerm_client_config" "current" {}

# Workbook for custom dashboards
resource "azurerm_application_insights_workbook" "agent_performance" {
  count               = var.enable_custom_metrics ? 1 : 0
  name                = "workbook-agent-performance-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  display_name        = "Agent Performance Dashboard"
  source_id           = azurerm_application_insights.main.id

  data_json = jsonencode({
    version = "Notebook/1.0"
    items = [
      {
        type = 1
        content = {
          json = "## Agent Performance Metrics\n\nReal-time monitoring of multi-agent system performance"
        }
      },
      {
        type = 3
        content = {
          version = "KqlItem/1.0"
          query   = "requests | summarize RequestCount = count() by bin(timestamp, 5m), name | render timechart"
          size    = 0
        }
      },
      {
        type = 3
        content = {
          version = "KqlItem/1.0"
          query   = "exceptions | summarize ExceptionCount = count() by bin(timestamp, 5m), type | render timechart"
          size    = 0
        }
      }
    ]
  })

  tags = var.tags
}
