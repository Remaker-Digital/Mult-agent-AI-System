output "application_gateway_id" {
  description = "ID of the Application Gateway"
  value       = azurerm_application_gateway.main.id
}

output "application_gateway_name" {
  description = "Name of the Application Gateway"
  value       = azurerm_application_gateway.main.name
}

output "public_ip_id" {
  description = "ID of the public IP address"
  value       = azurerm_public_ip.gateway.id
}

output "public_ip_address" {
  description = "Public IP address of the Application Gateway"
  value       = azurerm_public_ip.gateway.ip_address
}

output "public_ip_fqdn" {
  description = "FQDN of the Application Gateway public IP"
  value       = azurerm_public_ip.gateway.fqdn
}

output "backend_address_pool_ids" {
  description = "IDs of backend address pools"
  value       = azurerm_application_gateway.main.backend_address_pool
}

output "waf_policy_id" {
  description = "ID of the WAF policy"
  value       = var.enable_waf ? azurerm_web_application_firewall_policy.main[0].id : null
}
