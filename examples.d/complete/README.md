# Complete Example

This example demonstrates a full 3-tier architecture (web, app, data) with:

- Virtual Network with 10.0.0.0/16 address space
- Three subnets (web, app, data)
- Network Security Groups with custom rules for each tier
- Route tables for routing traffic through a firewall/NVA
- Service endpoints for Azure services
- Proper security segmentation between tiers

## Architecture

```
Internet
   ↓
[Web Subnet] (10.0.1.0/24)
   ↓ HTTPS/HTTP
[App Subnet] (10.0.2.0/24) → Firewall (10.0.100.4)
   ↓ SQL
[Data Subnet] (10.0.3.0/24) → Firewall (10.0.100.4)
```

## Usage

1. Update the resource group module path in `main.tf`
2. Adjust the firewall IP address in the route tables
3. Run Terraform:

```bash
terraform init
terraform plan
terraform apply
```

## What Gets Created

- 1 Virtual Network
- 3 Subnets
- 3 Network Security Groups (one per subnet)
- Multiple NSG rules per subnet
- 2 Route Tables (for app and data subnets)
- Routes to firewall/NVA
