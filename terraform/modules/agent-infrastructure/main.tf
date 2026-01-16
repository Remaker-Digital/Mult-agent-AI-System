# Container Groups for each AI agent
resource "azurerm_container_group" "agents" {
  for_each = var.agents

  name                = "aci-${each.value.name}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  restart_policy      = "Always"

  ip_address_type = "Private"
  subnet_ids      = [var.subnet_id]

  # Use managed identity for ACR authentication
  identity {
    type         = "UserAssigned"
    identity_ids = [var.user_assigned_identity_id]
  }

  image_registry_credential {
    server                    = var.container_registry_server
    user_assigned_identity_id = var.user_assigned_identity_id
  }

  container {
    name   = each.value.name
    image  = "${var.container_registry_server}/${var.agent_container_image}"
    cpu    = var.agent_cpu
    memory = var.agent_memory

    ports {
      port     = each.value.port
      protocol = "TCP"
    }

    # Environment variables for agent configuration
    environment_variables = {
      AGENT_NAME                = each.value.name
      AGENT_DESCRIPTION         = each.value.description
      ENVIRONMENT               = var.environment
      ASPNETCORE_ENVIRONMENT    = var.environment
      APPLICATIONINSIGHTS_CONNECTION_STRING = var.app_insights_connection_string
    }

    # Secure environment variables (from Key Vault)
    secure_environment_variables = {
      COSMOS_DB_ENDPOINT     = var.cosmos_db_endpoint
      COSMOS_DB_KEY          = "@Microsoft.KeyVault(SecretUri=${var.cosmos_db_key_secret_id})"
      REDIS_HOSTNAME         = var.redis_hostname
      REDIS_KEY              = "@Microsoft.KeyVault(SecretUri=${var.redis_key_secret_id})"
      APPLICATIONINSIGHTS_INSTRUMENTATION_KEY = var.app_insights_instrumentation_key
    }

    # Liveness probe
    liveness_probe {
      http_get {
        path   = "/health"
        port   = each.value.port
        scheme = "Http"
      }
      initial_delay_seconds = 30
      period_seconds        = 10
      failure_threshold     = 3
      timeout_seconds       = 5
    }

    # Readiness probe
    readiness_probe {
      http_get {
        path   = "/ready"
        port   = each.value.port
        scheme = "Http"
      }
      initial_delay_seconds = 10
      period_seconds        = 5
      failure_threshold     = 3
      timeout_seconds       = 3
    }
  }

  diagnostics {
    log_analytics {
      workspace_id  = var.log_analytics_workspace_id
      workspace_key = var.log_analytics_workspace_key
    }
  }

  tags = lookup(var.agent_tags, each.key, merge(var.tags, {
    Agent = each.value.name
  }))
}

# Autoscaling profiles (simulated via Azure Automation)
# Note: Azure Container Instances don't have native autoscaling
# This creates the foundation for custom autoscaling logic
resource "azurerm_automation_account" "autoscaling" {
  count               = var.enable_autoscaling ? 1 : 0
  name                = "aa-autoscale-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "Basic"

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

# Runbook for autoscaling logic
resource "azurerm_automation_runbook" "scale_agents" {
  count                   = var.enable_autoscaling ? 1 : 0
  name                    = "ScaleAgents"
  location                = var.location
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.autoscaling[0].name
  log_verbose             = true
  log_progress            = true
  runbook_type            = "PowerShell"

  content = <<-RUNBOOK
    param(
        [string]$ResourceGroupName,
        [string]$AgentName,
        [int]$TargetInstances
    )

    # Authenticate using Managed Identity
    Connect-AzAccount -Identity

    # Get current container groups
    $containerGroups = Get-AzContainerGroup -ResourceGroupName $ResourceGroupName | Where-Object { $_.Name -like "*$AgentName*" }
    $currentCount = $containerGroups.Count

    Write-Output "Current instances: $currentCount, Target instances: $TargetInstances"

    if ($TargetInstances -gt $currentCount) {
        # Scale up
        $instancesToCreate = $TargetInstances - $currentCount
        Write-Output "Scaling up: creating $instancesToCreate instances"
        # Add scale-up logic here
    } elseif ($TargetInstances -lt $currentCount) {
        # Scale down
        $instancesToRemove = $currentCount - $TargetInstances
        Write-Output "Scaling down: removing $instancesToRemove instances"
        # Add scale-down logic here
    } else {
        Write-Output "No scaling needed"
    }
  RUNBOOK

  tags = var.tags
}

# Schedule for autoscaling checks
resource "azurerm_automation_schedule" "scale_check" {
  count                   = var.enable_autoscaling ? 1 : 0
  name                    = "ScaleCheckSchedule"
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.autoscaling[0].name
  frequency               = "Hour"
  interval                = 1
  description             = "Check agent metrics and scale accordingly"
}

# RBAC: Grant automation account permission to manage container groups
resource "azurerm_role_assignment" "autoscaling_contributor" {
  count                = var.enable_autoscaling ? 1 : 0
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.resource_group_name}"
  role_definition_name = "Contributor"
  principal_id         = azurerm_automation_account.autoscaling[0].identity[0].principal_id
}

# Data source for current Azure configuration
data "azurerm_client_config" "current" {}

# Diagnostic settings for container groups
resource "azurerm_monitor_diagnostic_setting" "agents" {
  for_each = var.agents

  name                       = "diag-${each.value.name}-${var.environment}"
  target_resource_id         = azurerm_container_group.agents[each.key].id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "ContainerInstanceLog"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
