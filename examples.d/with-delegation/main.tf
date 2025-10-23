# Example: Network with subnet delegation for managed services

# Create the Resource Group first
module "resource_group" {
  source = "app.terraform.io/mikevh/terraform-azurerm-resource-group/azurerm"
  
  project     = "delegated-network"
  environment = "prod"
  location    = "eastus"
  repo_name   = "terraform-azurerm-networking"
  repo_path   = "github.com/michielvha/terraform-azurerm-networking"
  contact     = "team@example.com"
}

# Network with delegated subnets for various Azure services
module "networking" {
  source = "../../"
  
  resource_group = module.resource_group
  environment    = "prod"
  address_space  = ["10.2.0.0/16"]
  
  subnets = {
    # Subnet for Azure SQL Managed Instance
    sql-mi = {
      address_prefixes  = ["10.2.1.0/24"]
      service_endpoints = ["Microsoft.Sql"]
      
      delegation = {
        name = "sql-mi-delegation"
        service_delegation = {
          name = "Microsoft.Sql/managedInstances"
          actions = [
            "Microsoft.Network/virtualNetworks/subnets/join/action",
            "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
            "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"
          ]
        }
      }
      
      nsg_rules = {
        allow_management_inbound = {
          priority                   = 106
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_ranges    = ["9000", "9003", "1438", "1440", "1452"]
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }
      }
    }
    
    # Subnet for Azure Container Instances
    aci = {
      address_prefixes = ["10.2.2.0/24"]
      
      delegation = {
        name = "aci-delegation"
        service_delegation = {
          name = "Microsoft.ContainerInstance/containerGroups"
          actions = [
            "Microsoft.Network/virtualNetworks/subnets/action"
          ]
        }
      }
    }
    
    # Subnet for App Service Integration
    app-service = {
      address_prefixes  = ["10.2.3.0/24"]
      service_endpoints = ["Microsoft.Storage", "Microsoft.Sql"]
      
      delegation = {
        name = "app-service-delegation"
        service_delegation = {
          name = "Microsoft.Web/serverFarms"
          actions = [
            "Microsoft.Network/virtualNetworks/subnets/action"
          ]
        }
      }
      
      nsg_rules = {
        allow_https_outbound = {
          priority                   = 100
          direction                  = "Outbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "443"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }
      }
    }
  }
  
  # Add delegation-specific tags
  custom_tags = {
    has-delegations = "true"
  }
}
