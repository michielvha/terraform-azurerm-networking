# Simple Example

This example demonstrates a basic networking setup with:

- Virtual Network with 10.1.0.0/16 address space
- Two simple subnets
- Basic NSG rules
- No route tables (using default Azure routing)

## Usage

1. Update the resource group module path in `main.tf`
2. Run Terraform:

```bash
terraform init
terraform plan
terraform apply
```

## What Gets Created

- 1 Virtual Network
- 2 Subnets
- 2 Network Security Groups
- 1 NSG rule (SSH access on default subnet)
