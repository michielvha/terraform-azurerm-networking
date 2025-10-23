# Subnet Delegation Example

This example demonstrates subnet delegation for Azure managed services:

- SQL Managed Instance subnet
- Azure Container Instances subnet
- App Service Integration subnet

## Subnet Delegation

Subnet delegation allows Azure services to create service-specific resources in your subnet. This is required for:

- Azure SQL Managed Instance
- Azure Container Instances
- App Service VNet Integration
- Azure NetApp Files
- Azure Databricks
- And more...

## Usage

1. Update the resource group module path in `main.tf`
2. Run Terraform:

```bash
terraform init
terraform plan
terraform apply
```

## Important Notes

- Each delegated subnet can only be delegated to ONE service
- Some services have minimum subnet size requirements (e.g., SQL MI needs /24 or larger)
- Delegated subnets cannot be used for other resources
- NSG rules for delegated subnets must allow service-specific traffic

## What Gets Created

- 1 Virtual Network
- 3 Delegated Subnets (SQL MI, ACI, App Service)
- 3 Network Security Groups
- Required NSG rules for managed services
