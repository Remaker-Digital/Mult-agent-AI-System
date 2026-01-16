output "search_service_id" {
  description = "ID of the Cognitive Search service"
  value       = azurerm_search_service.main.id
}

output "search_service_name" {
  description = "Name of the Cognitive Search service"
  value       = azurerm_search_service.main.name
}

output "search_service_endpoint" {
  description = "Endpoint URL of the Cognitive Search service"
  value       = "https://${azurerm_search_service.main.name}.search.windows.net"
}

output "search_admin_key_secret_id" {
  description = "Key Vault secret ID for the search admin key"
  value       = azurerm_key_vault_secret.search_admin_key.id
}

output "search_query_key_secret_id" {
  description = "Key Vault secret ID for the search query key"
  value       = azurerm_key_vault_secret.search_query_key.id
}

output "search_endpoint_secret_id" {
  description = "Key Vault secret ID for the search endpoint"
  value       = azurerm_key_vault_secret.search_endpoint.id
}

output "search_service_identity_principal_id" {
  description = "Principal ID of the search service managed identity"
  value       = azurerm_search_service.main.identity[0].principal_id
}

output "private_endpoint_id" {
  description = "ID of the private endpoint (if enabled)"
  value       = var.enable_private_endpoint ? azurerm_private_endpoint.search[0].id : null
}

output "private_ip_address" {
  description = "Private IP address of the search service (if private endpoint enabled)"
  value       = var.enable_private_endpoint ? azurerm_private_endpoint.search[0].private_service_connection[0].private_ip_address : null
}
