terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }

  backend "azurerm" {
    # Backend configuration should be provided via backend config file or command line
    # Example: terraform init -backend-config="environments/dev/backend.tfvars"
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = var.environment == "dev" ? true : false
      recover_soft_deleted_key_vaults = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = var.environment == "production" ? true : false
    }
  }
}

# Random suffix for globally unique resource names
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "rg-${var.project_name}-${var.environment}-${var.location}"
  location = var.location

  tags = merge(var.tags, {
    Environment = var.environment
    ManagedBy   = "Terraform"
  })
}

# Networking Module
module "networking" {
  source = "./modules/networking"

  project_name       = var.project_name
  environment        = var.environment
  location           = var.location
  resource_group_name = azurerm_resource_group.main.name
  vnet_address_space = var.vnet_address_space
  subnet_config      = var.subnet_config
  tags               = var.tags
}

# Observability Module (Application Insights, Log Analytics)
# Created first as other modules depend on it for diagnostics
module "observability" {
  source = "./modules/observability"

  project_name        = var.project_name
  environment         = var.environment
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  resource_suffix     = random_string.suffix.result

  # Alert configuration
  alert_email_addresses     = var.alert_email_addresses
  monthly_budget_amount     = var.monthly_budget_amount
  budget_alert_thresholds   = var.budget_alert_thresholds

  # Metrics
  enable_custom_metrics     = var.enable_custom_metrics

  tags                      = var.tags
}

# Security Module (Key Vault and Managed Identities)
module "security" {
  source = "./modules/security"

  project_name        = var.project_name
  environment         = var.environment
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  resource_suffix     = random_string.suffix.result
  subnet_id           = module.networking.private_endpoint_subnet_id
  private_dns_zone_id = module.networking.private_dns_zone_ids["keyvault"]
  log_analytics_workspace_id = module.observability.log_analytics_workspace_id
  tags                = var.tags

  depends_on = [module.networking, module.observability]
}

# Container Registry Module
module "container_registry" {
  source = "./modules/container-registry"

  project_name        = var.project_name
  environment         = var.environment
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  resource_suffix     = random_string.suffix.result
  sku                 = var.acr_sku
  geo_replication_locations = var.acr_geo_replication_locations
  subnet_id           = module.networking.private_endpoint_subnet_id
  private_dns_zone_id = module.networking.private_dns_zone_ids["acr"]
  log_analytics_workspace_id = module.observability.log_analytics_workspace_id
  tags                = var.tags

  depends_on = [module.networking, module.observability]
}

# Data Layer Module (Cosmos DB and Redis)
module "data_layer" {
  source = "./modules/data-layer"

  project_name        = var.project_name
  environment         = var.environment
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  resource_suffix     = random_string.suffix.result

  # Cosmos DB configuration
  cosmos_db_consistency_level          = var.cosmos_db_consistency_level
  cosmos_db_max_interval_in_seconds    = var.cosmos_db_max_interval_in_seconds
  cosmos_db_max_staleness_prefix       = var.cosmos_db_max_staleness_prefix
  cosmos_db_autoscale_max_throughput   = var.cosmos_db_autoscale_max_throughput
  cosmos_db_databases                  = var.cosmos_db_databases

  # Redis configuration
  redis_capacity                       = var.redis_capacity
  redis_family                         = var.redis_family
  redis_sku_name                       = var.redis_sku_name
  redis_enable_non_ssl_port            = false
  redis_minimum_tls_version            = "1.3"

  subnet_id                            = module.networking.private_endpoint_subnet_id
  cosmos_private_dns_zone_id           = module.networking.private_dns_zone_ids["cosmos"]
  redis_private_dns_zone_id            = module.networking.private_dns_zone_ids["redis"]
  key_vault_id                         = module.security.key_vault_id
  log_analytics_workspace_id           = module.observability.log_analytics_workspace_id
  tags                                 = var.tags

  depends_on = [module.networking, module.security, module.observability]
}

# Agent Infrastructure Module (Container Instances)
module "agent_infrastructure" {
  source = "./modules/agent-infrastructure"

  project_name        = var.project_name
  environment         = var.environment
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name

  # Agent configuration
  agents                    = var.agents
  agent_container_image     = var.agent_container_image
  agent_cpu                 = var.agent_cpu
  agent_memory              = var.agent_memory

  # Networking
  subnet_id                 = module.networking.agent_subnet_id

  # Dependencies
  container_registry_id     = module.container_registry.registry_id
  container_registry_server = module.container_registry.login_server
  key_vault_id              = module.security.key_vault_id

  # Data layer connections
  cosmos_db_endpoint        = module.data_layer.cosmos_db_endpoint
  cosmos_db_key_secret_id   = module.data_layer.cosmos_db_key_secret_id
  redis_hostname            = module.data_layer.redis_hostname
  redis_key_secret_id       = module.data_layer.redis_key_secret_id

  # Observability
  app_insights_instrumentation_key = module.observability.app_insights_instrumentation_key
  app_insights_connection_string   = module.observability.app_insights_connection_string
  log_analytics_workspace_id       = module.observability.log_analytics_workspace_id
  log_analytics_workspace_key      = module.observability.log_analytics_workspace_key

  # Scaling configuration
  enable_autoscaling        = var.enable_autoscaling
  min_instance_count        = var.min_instance_count
  max_instance_count        = var.max_instance_count

  # Managed identity
  user_assigned_identity_id = module.security.user_assigned_identity_id

  tags                      = var.tags

  depends_on = [
    module.networking,
    module.security,
    module.container_registry,
    module.data_layer,
    module.observability
  ]
}

# Application Gateway Module
module "gateway" {
  source = "./modules/gateway"

  project_name        = var.project_name
  environment         = var.environment
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  resource_suffix     = random_string.suffix.result

  # Networking
  subnet_id                 = module.networking.gateway_subnet_id

  # Backend configuration
  backend_address_pools     = module.agent_infrastructure.agent_backend_pools

  # WAF configuration
  enable_waf                = var.enable_waf
  waf_mode                  = var.waf_mode

  # SSL/TLS configuration
  enable_http2              = true
  ssl_policy_type           = "Predefined"
  ssl_policy_name           = "AppGwSslPolicy20220101"

  # Observability
  log_analytics_workspace_id = module.observability.log_analytics_workspace_id

  tags                      = var.tags

  depends_on = [
    module.networking,
    module.agent_infrastructure,
    module.observability
  ]
}
