# Example: Simple networking setup with basic subnets

# Create the Resource Group first
module "resource_group" {
  source  = "app.terraform.io/mikevh/terraform-azurerm-resource-group/azurerm"
  
  project     = "simple-network"
  environment = "prd"
  location    = "eastus"
  repo_name   = "terraform-azurerm-networking"
  repo_path   = "github.com/michielvha/terraform-azurerm-networking"
  contact     = "team@example.com"
}

# Create a simple network with basic subnets
module "networking" {
  source = "../../"
  
  resource_group = module.resource_group
  environment    = module.resource_group.environment
  address_space  = ["10.1.0.0/16"]
  
  subnets = {
    # Simple subnet with minimal configuration
    default = {
      address_prefixes = ["10.1.1.0/24"]
      
      nsg_rules = {
        allow_ssh = {
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "22"
          source_address_prefix      = "10.0.0.0/8"  # Internal only
          destination_address_prefix = "*"
        }
      }
    }
    
    # Subnet without any NSG rules (empty NSG will be created)
    management = {
      address_prefixes = ["10.1.2.0/24"]
    }
  }
  
  # No custom tags - will just use RG tags + managed-by
}
