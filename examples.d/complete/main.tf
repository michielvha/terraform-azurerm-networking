# Example: Complete networking setup with web, app, and data tiers

# Create the Resource Group first
module "resource_group" {
  source = "app.terraform.io/mikevh/terraform-azurerm-resource-group/azurerm"
  
  project     = "myproject"
  environment = "dev"
  location    = "eastus"
  repo_name   = "terraform-azurerm-networking"
  repo_path   = "github.com/michielvha/terraform-azurerm-networking"
  contact     = "team@example.com"
}

# Create the Networking resources
module "networking" {
  source = "../../"  # Points to the root of this module
  
  resource_group = module.resource_group
  environment    = "dev"
  address_space  = ["10.0.0.0/16"]
  
  subnets = {
    # Web tier subnet - public facing
    web = {
      address_prefixes  = ["10.0.1.0/24"]
      service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
      
      nsg_rules = {
        allow_https = {
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "443"
          source_address_prefix      = "Internet"
          destination_address_prefix = "*"
        }
        allow_http = {
          priority                   = 110
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "80"
          source_address_prefix      = "Internet"
          destination_address_prefix = "*"
        }
        deny_all_inbound = {
          priority                   = 4096
          direction                  = "Inbound"
          access                     = "Deny"
          protocol                   = "*"
          source_port_range          = "*"
          destination_port_range     = "*"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }
      }
    }
    
    # Application tier subnet - middle tier
    app = {
      address_prefixes  = ["10.0.2.0/24"]
      service_endpoints = ["Microsoft.Sql", "Microsoft.Storage"]
      
      nsg_rules = {
        allow_from_web = {
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "443"
          source_address_prefix      = "10.0.1.0/24"  # web subnet
          destination_address_prefix = "*"
        }
        allow_app_ports = {
          priority                   = 110
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_ranges    = ["8080", "8443"]
          source_address_prefix      = "10.0.1.0/24"  # web subnet
          destination_address_prefix = "*"
        }
      }
      
      # Route all traffic through a firewall/NVA
      route_table_routes = {
        to_firewall = {
          address_prefix         = "0.0.0.0/0"
          next_hop_type          = "VirtualAppliance"
          next_hop_in_ip_address = "10.0.100.4"
        }
      }
    }
    
    # Data tier subnet - backend databases
    data = {
      address_prefixes  = ["10.0.3.0/24"]
      service_endpoints = ["Microsoft.Sql"]
      
      nsg_rules = {
        allow_sql_from_app = {
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_ranges    = ["1433", "1434"]
          source_address_prefix      = "10.0.2.0/24"  # app subnet
          destination_address_prefix = "*"
        }
        deny_all_other = {
          priority                   = 4096
          direction                  = "Inbound"
          access                     = "Deny"
          protocol                   = "*"
          source_port_range          = "*"
          destination_port_range     = "*"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }
      }
      
      route_table_routes = {
        to_firewall = {
          address_prefix         = "0.0.0.0/0"
          next_hop_type          = "VirtualAppliance"
          next_hop_in_ip_address = "10.0.100.4"
        }
      }
    }
  }
  
  # Optionally add networking-specific tags
  custom_tags = {
    network-tier = "3-tier"
  }
}
