# Examples

This directory contains various examples demonstrating how to use the Azure Networking Terraform module.

## Available Examples

### [Simple](./simple)
A basic networking setup with:
- 2 subnets
- Minimal NSG rules
- No route tables
- Good for development/testing environments

### [Complete](./complete)
A production-ready 3-tier architecture with:
- Web, App, and Data subnets
- Comprehensive NSG rules for each tier
- Route tables routing through firewall/NVA
- Service endpoints
- Proper network segmentation

### [With Delegation](./with-delegation)
Examples of subnet delegation for Azure managed services:
- Azure SQL Managed Instance
- Azure Container Instances (ACI)
- App Service VNet Integration
- Required NSG rules for delegated subnets

### [Kubernetes](./kubernetes)
**Production-ready network for Kubernetes clusters:**
- Single subnet optimized for K8s
- Pre-configured NSG rules for:
  - Kubernetes API Server (6443)
  - HTTP/HTTPS ingress (80/443)
  - Kubelet, NodePorts, SSH
- Service endpoints for ACR, Storage, Key Vault
- Works with AKS or self-managed Kubernetes
- Large address space (10.224.0.0/12) for pods/services
- **Perfect for getting started quickly!**

## Usage

Each example directory contains:
- `main.tf` - Main configuration
- `outputs.tf` - Output definitions
- `providers.tf` - Provider configuration
- `README.md` - Specific example documentation

To use any example:

1. Navigate to the example directory:
   ```bash
   cd examples/simple
   ```

2. Update the resource group module path in `main.tf`

3. Initialize and apply:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Notes

- All examples assume you have a separate resource group module
- Update the module source paths to match your directory structure
- Adjust IP ranges, rules, and configurations as needed for your use case
- Examples use placeholder values - replace with your actual values before applying
