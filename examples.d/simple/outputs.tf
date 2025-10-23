output "vnet_id" {
  description = "The ID of the Virtual Network"
  value       = module.networking.vnet_id
}

output "subnet_ids" {
  description = "Map of subnet names to their IDs"
  value       = module.networking.subnet_ids
}
