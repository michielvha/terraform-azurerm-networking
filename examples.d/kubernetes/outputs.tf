output "vnet_id" {
  description = "The ID of the Virtual Network for Kubernetes"
  value       = module.networking.vnet_id
}

output "vnet_name" {
  description = "The name of the Virtual Network"
  value       = module.networking.vnet_name
}

output "kubernetes_subnet_id" {
  description = "The ID of the Kubernetes subnet (use this for AKS)"
  value       = module.networking.subnet_ids["kubernetes"]
}

output "kubernetes_subnet_name" {
  description = "The name of the Kubernetes subnet"
  value       = module.networking.subnet_names["kubernetes"]
}

output "nsg_id" {
  description = "The ID of the NSG protecting the Kubernetes subnet"
  value       = module.networking.nsg_ids["kubernetes"]
}
