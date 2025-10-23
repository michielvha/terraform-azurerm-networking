output "vnet_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.main.id
}

output "vnet_name" {
  description = "Name of the virtual network"
  value       = azurerm_virtual_network.main.name
}

output "virtual_network_id" {
  description = "ID of the virtual network (deprecated, use vnet_id)"
  value       = azurerm_virtual_network.main.id
}

output "virtual_network_name" {
  description = "Name of the virtual network (deprecated, use vnet_name)"
  value       = azurerm_virtual_network.main.name
}

output "subnet_ids" {
  description = "Map of subnet names to IDs"
  value       = { for k, v in azurerm_subnet.subnets : k => v.id }
}

output "subnet_names" {
  description = "Map of subnet keys to names"
  value       = { for k, v in azurerm_subnet.subnets : k => v.name }
}

output "nsg_ids" {
  description = "Map of NSG names to IDs"
  value       = { for k, v in azurerm_network_security_group.subnets : k => v.id }
}

output "nsg_names" {
  description = "Map of NSG keys to names"
  value       = { for k, v in azurerm_network_security_group.subnets : k => v.name }
}

output "route_table_ids" {
  description = "Map of route table names to IDs"
  value       = { for k, v in azurerm_route_table.subnets : k => v.id }
}

output "route_table_names" {
  description = "Map of route table keys to names"
  value       = { for k, v in azurerm_route_table.subnets : k => v.name }
}
