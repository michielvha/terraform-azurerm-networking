# Azure Networking Terraform Module

This Terraform module creates Azure Virtual Networks (VNets) with subnets, Network Security Groups (NSGs), and route tables with standardized naming conventions and tagging.

## Overview

The module simplifies the creation of Azure networking infrastructure by:

- Creating Virtual Networks with customizable address spaces and DNS settings
- Generating standardized resource names based on environment
- Creating subnets with automatic NSG and route table associations
- Supporting subnet delegations for Azure services (e.g., AKS, App Service)
- Applying Network Security Group (NSG) rules per subnet
- Configuring route tables with custom routes per subnet
- Supporting service endpoints for Azure services
- Applying consistent tags inherited from resource group
- Optional DDoS Protection Plan integration

## Usage

See the [examples.d](./examples.d/) directory for complete usage examples:
- [Simple](./examples.d/simple/main.tf) - Basic network with minimal configuration
- [Complete](./examples.d/complete/main.tf) - Full-featured multi-tier architecture
- [Kubernetes](./examples.d/kubernetes/main.tf) - Network configuration for AKS
- [With Delegation](./examples.d/with-delegation/main.tf) - Subnet delegation examples

## Naming Convention

The module automatically generates resource names using the following pattern:

**Virtual Network:**
```
lz-{environment}-vnet
```

**Subnets:**
```
lz-{environment}-{subnet_key}-subnet
```

**Network Security Groups:**
```
lz-{environment}-{subnet_key}-nsg
```

**Route Tables:**
```
lz-{environment}-{subnet_key}-rt
```

**Environment values:**
- `production`
- `acceptance`
- `integration`
- `development`

**Example:** In development environment with a "web" subnet:
- VNet: `lz-development-vnet`
- Subnet: `lz-development-web-subnet`
- NSG: `lz-development-web-nsg`
- Route Table: `lz-development-web-rt`

## Features

### Virtual Network
- Configurable address space with CIDR validation
- Custom DNS servers (defaults to Azure DNS)
- Optional DDoS Protection Plan integration

### Subnets
- Multiple subnets with individual configurations
- Address prefix validation
- Service endpoints for Azure services (Storage, SQL, KeyVault, etc.)
- Subnet delegation support for specialized Azure services

### Network Security Groups (NSGs)
- Automatic NSG creation per subnet
- Configurable security rules with validation
- Support for single or multiple port ranges
- Source/destination prefix or prefix lists
- Priority-based rule ordering (100-4096)
- Automatic NSG-to-subnet association

### Route Tables
- Optional route tables per subnet (only created when routes are defined)
- Support for all Azure next hop types
- Custom route definitions
- Automatic route table-to-subnet association

### Service Endpoints
Supported service endpoints include:
- `Microsoft.Storage`
- `Microsoft.Sql`
- `Microsoft.KeyVault`
- `Microsoft.AzureActiveDirectory`
- `Microsoft.ServiceBus`
- `Microsoft.EventHub`
- `Microsoft.Web`
- `Microsoft.ContainerRegistry`

### Subnet Delegations
Support for delegating subnets to Azure services, including:
- Azure Kubernetes Service (AKS)
- Azure Container Instances
- Azure App Service
- Azure Database for PostgreSQL/MySQL
- Azure Databricks
- And more...

## Tags

The module automatically applies tags from the resource group plus:

- All tags from the `resource_group` object
- Custom tags from `custom_tags` variable
- `managed-by`: "terraform"

Tags are applied to:
- Virtual Network
- Network Security Groups
- Route Tables

## Network Security Rules

NSG rules support the following configurations:

- **Priority**: 100-4096 (lower numbers processed first)
- **Direction**: `Inbound` or `Outbound`
- **Access**: `Allow` or `Deny`
- **Protocol**: `Tcp`, `Udp`, `Icmp`, or `*` (any)
- **Port Ranges**: Single port or multiple ports
- **Address Prefixes**: Single prefix, multiple prefixes, or Azure service tags

## Route Tables

Route tables support the following next hop types:

- **VirtualNetworkGateway**: Route to VPN/ExpressRoute gateway
- **VnetLocal**: Route within the virtual network
- **Internet**: Route to Internet
- **VirtualAppliance**: Route to network virtual appliance (requires IP address)
- **None**: Drop traffic (black hole route)

## Prerequisites

- Terraform >= 0.13
- Azure provider configured
- Existing Resource Group (can be created with the companion resource group module)
- Appropriate Azure permissions to create networking resources
- DDoS Protection Plan (if enabling DDoS protection)

## Notes

- NSGs are automatically created for every subnet, even if no rules are defined
- Route tables are only created for subnets that have routes defined
- Service endpoints are applied at the subnet level
- Subnet delegations are exclusive - a subnet can only be delegated to one service
- When using `VirtualAppliance` next hop type, you must provide `next_hop_in_ip_address`
- DDoS Protection Plans incur additional costs - ensure you understand pricing before enabling
- Address spaces and subnet prefixes are validated as proper CIDR blocks
- NSG rule priorities must be unique within each NSG
- The module inherits tags from the resource group and merges them with custom tags

<!-- BEGIN_TF_DOCS -->
