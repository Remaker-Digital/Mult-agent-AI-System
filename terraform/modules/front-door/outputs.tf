output "frontdoor_id" {
  description = "ID of the Front Door profile"
  value       = azurerm_cdn_frontdoor_profile.main.id
}

output "frontdoor_endpoint_hostname" {
  description = "Hostname of the Front Door endpoint"
  value       = azurerm_cdn_frontdoor_endpoint.main.host_name
}

output "frontdoor_endpoint_id" {
  description = "ID of the Front Door endpoint"
  value       = azurerm_cdn_frontdoor_endpoint.main.id
}

output "frontdoor_profile_name" {
  description = "Name of the Front Door profile"
  value       = azurerm_cdn_frontdoor_profile.main.name
}

output "origin_group_id" {
  description = "ID of the origin group"
  value       = azurerm_cdn_frontdoor_origin_group.gateway.id
}

output "waf_policy_id" {
  description = "ID of the WAF policy"
  value       = var.enable_waf ? azurerm_cdn_frontdoor_firewall_policy.main[0].id : null
}

output "public_endpoint_url" {
  description = "Public URL for accessing the service via Front Door"
  value       = "https://${azurerm_cdn_frontdoor_endpoint.main.host_name}"
}
