output "vnet_id" {
  description = "The ID of the Virtual Network"
  value       = module.networking.vnet_id
}

output "sql_mi_subnet_id" {
  description = "The ID of the SQL Managed Instance subnet"
  value       = module.networking.subnet_ids["sql-mi"]
}

output "aci_subnet_id" {
  description = "The ID of the Azure Container Instances subnet"
  value       = module.networking.subnet_ids["aci"]
}

output "app_service_subnet_id" {
  description = "The ID of the App Service subnet"
  value       = module.networking.subnet_ids["app-service"]
}
