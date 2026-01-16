output "agent_container_group_ids" {
  description = "Map of agent names to container group IDs"
  value       = { for k, v in azurerm_container_group.agents : k => v.id }
}

output "agent_container_group_names" {
  description = "Map of agent names to container group names"
  value       = { for k, v in azurerm_container_group.agents : k => v.name }
}

output "agent_ip_addresses" {
  description = "Map of agent names to IP addresses"
  value       = { for k, v in azurerm_container_group.agents : k => v.ip_address }
}

output "agent_fqdns" {
  description = "Map of agent names to FQDNs"
  value       = { for k, v in azurerm_container_group.agents : k => v.fqdn }
}

output "agent_backend_pools" {
  description = "Backend pool configuration for Application Gateway"
  value = [
    for k, v in azurerm_container_group.agents : {
      name         = "${v.name}-backend"
      ip_addresses = [v.ip_address]
      fqdns        = []
    }
  ]
}

output "automation_account_id" {
  description = "ID of the automation account for autoscaling"
  value       = var.enable_autoscaling ? azurerm_automation_account.autoscaling[0].id : null
}

output "automation_account_name" {
  description = "Name of the automation account for autoscaling"
  value       = var.enable_autoscaling ? azurerm_automation_account.autoscaling[0].name : null
}
