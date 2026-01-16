output "vnet_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.main.id
}

output "vnet_name" {
  description = "Name of the virtual network"
  value       = azurerm_virtual_network.main.name
}

output "gateway_subnet_id" {
  description = "ID of the gateway subnet"
  value       = azurerm_subnet.gateway.id
}

output "agent_subnet_id" {
  description = "ID of the agents subnet"
  value       = azurerm_subnet.agents.id
}

output "private_endpoint_subnet_id" {
  description = "ID of the private endpoints subnet"
  value       = azurerm_subnet.private_endpoints.id
}

output "subnet_ids" {
  description = "Map of subnet names to IDs"
  value = {
    gateway           = azurerm_subnet.gateway.id
    agents            = azurerm_subnet.agents.id
    private_endpoints = azurerm_subnet.private_endpoints.id
  }
}

output "nsg_ids" {
  description = "Map of NSG names to IDs"
  value = {
    gateway           = azurerm_network_security_group.gateway.id
    agents            = azurerm_network_security_group.agents.id
    private_endpoints = azurerm_network_security_group.private_endpoints.id
  }
}

output "private_dns_zone_ids" {
  description = "Map of private DNS zone names to IDs"
  value = {
    cosmos   = azurerm_private_dns_zone.cosmos.id
    redis    = azurerm_private_dns_zone.redis.id
    keyvault = azurerm_private_dns_zone.keyvault.id
    acr      = azurerm_private_dns_zone.acr.id
    search   = azurerm_private_dns_zone.search.id
  }
}

output "private_dns_zone_names" {
  description = "Map of service names to private DNS zone names"
  value = {
    cosmos   = azurerm_private_dns_zone.cosmos.name
    redis    = azurerm_private_dns_zone.redis.name
    keyvault = azurerm_private_dns_zone.keyvault.name
    acr      = azurerm_private_dns_zone.acr.name
    search   = azurerm_private_dns_zone.search.name
  }
}
