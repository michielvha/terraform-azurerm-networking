# Outputs from the networking module

output "vnet_id" {
  description = "The ID of the Virtual Network"
  value       = module.networking.vnet_id
}

output "vnet_name" {
  description = "The name of the Virtual Network"
  value       = module.networking.vnet_name
}

output "subnet_ids" {
  description = "Map of subnet names to their IDs"
  value       = module.networking.subnet_ids
}

output "nsg_ids" {
  description = "Map of NSG names to their IDs"
  value       = module.networking.nsg_ids
}

output "route_table_ids" {
  description = "Map of Route Table names to their IDs"
  value       = module.networking.route_table_ids
}
