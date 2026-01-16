# Resource Group Outputs
output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_location" {
  description = "Location of the resource group"
  value       = azurerm_resource_group.main.location
}

# Networking Outputs
output "vnet_id" {
  description = "ID of the virtual network"
  value       = module.networking.vnet_id
}

output "vnet_name" {
  description = "Name of the virtual network"
  value       = module.networking.vnet_name
}

output "subnet_ids" {
  description = "Map of subnet names to IDs"
  value       = module.networking.subnet_ids
}

# Container Registry Outputs
output "container_registry_id" {
  description = "ID of the container registry"
  value       = module.container_registry.registry_id
}

output "container_registry_login_server" {
  description = "Login server URL for the container registry"
  value       = module.container_registry.login_server
}

output "container_registry_name" {
  description = "Name of the container registry"
  value       = module.container_registry.registry_name
}

# Data Layer Outputs
output "cosmos_db_endpoint" {
  description = "Endpoint URL for Cosmos DB"
  value       = module.data_layer.cosmos_db_endpoint
}

output "cosmos_db_account_name" {
  description = "Name of the Cosmos DB account"
  value       = module.data_layer.cosmos_db_account_name
}

output "cosmos_db_database_names" {
  description = "Names of Cosmos DB databases"
  value       = module.data_layer.cosmos_db_database_names
}

output "redis_hostname" {
  description = "Hostname for Redis cache"
  value       = module.data_layer.redis_hostname
}

output "redis_ssl_port" {
  description = "SSL port for Redis cache"
  value       = module.data_layer.redis_ssl_port
}

output "redis_name" {
  description = "Name of the Redis cache"
  value       = module.data_layer.redis_name
}

# Security Outputs
output "key_vault_id" {
  description = "ID of the Key Vault"
  value       = module.security.key_vault_id
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = module.security.key_vault_uri
}

output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = module.security.key_vault_name
}

output "user_assigned_identity_id" {
  description = "ID of the user-assigned managed identity"
  value       = module.security.user_assigned_identity_id
}

output "user_assigned_identity_principal_id" {
  description = "Principal ID of the user-assigned managed identity"
  value       = module.security.user_assigned_identity_principal_id
}

output "user_assigned_identity_client_id" {
  description = "Client ID of the user-assigned managed identity"
  value       = module.security.user_assigned_identity_client_id
}

# Observability Outputs
output "app_insights_instrumentation_key" {
  description = "Instrumentation key for Application Insights"
  value       = module.observability.app_insights_instrumentation_key
  sensitive   = true
}

output "app_insights_connection_string" {
  description = "Connection string for Application Insights"
  value       = module.observability.app_insights_connection_string
  sensitive   = true
}

output "app_insights_app_id" {
  description = "Application ID for Application Insights"
  value       = module.observability.app_insights_app_id
}

output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace"
  value       = module.observability.log_analytics_workspace_id
}

output "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace"
  value       = module.observability.log_analytics_workspace_name
}

# Agent Infrastructure Outputs
output "agent_container_group_ids" {
  description = "Map of agent names to container group IDs"
  value       = module.agent_infrastructure.agent_container_group_ids
}

output "agent_container_group_names" {
  description = "Map of agent names to container group names"
  value       = module.agent_infrastructure.agent_container_group_names
}

output "agent_ip_addresses" {
  description = "Map of agent names to IP addresses"
  value       = module.agent_infrastructure.agent_ip_addresses
}

# Application Gateway Outputs
output "application_gateway_id" {
  description = "ID of the Application Gateway"
  value       = module.gateway.application_gateway_id
}

output "application_gateway_name" {
  description = "Name of the Application Gateway"
  value       = module.gateway.application_gateway_name
}

output "application_gateway_public_ip" {
  description = "Public IP address of the Application Gateway"
  value       = module.gateway.public_ip_address
}

output "application_gateway_fqdn" {
  description = "FQDN of the Application Gateway"
  value       = module.gateway.public_ip_fqdn
}

# Cognitive Search Outputs
output "cognitive_search_endpoint" {
  description = "Endpoint URL of the Cognitive Search service"
  value       = var.enable_cognitive_search ? module.cognitive_search[0].search_service_endpoint : null
}

output "cognitive_search_name" {
  description = "Name of the Cognitive Search service"
  value       = var.enable_cognitive_search ? module.cognitive_search[0].search_service_name : null
}

output "cognitive_search_id" {
  description = "ID of the Cognitive Search service"
  value       = var.enable_cognitive_search ? module.cognitive_search[0].search_service_id : null
}

# Front Door Outputs
output "front_door_endpoint_hostname" {
  description = "Hostname of the Front Door endpoint"
  value       = var.enable_front_door ? module.front_door[0].frontdoor_endpoint_hostname : null
}

output "front_door_public_url" {
  description = "Public URL for accessing the service via Front Door"
  value       = var.enable_front_door ? module.front_door[0].public_endpoint_url : null
}

output "front_door_id" {
  description = "ID of the Front Door profile"
  value       = var.enable_front_door ? module.front_door[0].frontdoor_id : null
}

# Summary Output for CI/CD
output "deployment_summary" {
  description = "Summary of deployed resources for CI/CD integration"
  value = {
    environment              = var.environment
    location                 = var.location
    resource_group          = azurerm_resource_group.main.name
    container_registry      = module.container_registry.login_server
    application_gateway_ip  = module.gateway.public_ip_address
    application_gateway_fqdn = module.gateway.public_ip_fqdn
    front_door_url          = var.enable_front_door ? module.front_door[0].public_endpoint_url : "Not enabled"
    cosmos_db_endpoint      = module.data_layer.cosmos_db_endpoint
    redis_hostname          = module.data_layer.redis_hostname
    cognitive_search_endpoint = var.enable_cognitive_search ? module.cognitive_search[0].search_service_endpoint : "Not enabled"
    key_vault_uri           = module.security.key_vault_uri
    log_analytics_workspace = module.observability.log_analytics_workspace_name
  }
}
