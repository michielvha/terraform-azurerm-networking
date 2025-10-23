# Example: Basic Kubernetes Networking Setup

# Create the Resource Group first
module "resource_group" {
  source = "app.terraform.io/mikevh/terraform-azurerm-resource-group/azurerm"
  
  project     = "k8s-cluster"
  environment = "dev"
  location    = "eastus"
  repo_name   = "terraform-azurerm-networking"
  repo_path   = "github.com/michielvha/terraform-azurerm-networking"
  contact     = "team@example.com"
}

# Create basic networking for Kubernetes cluster
module "networking" {
  source = "../../"
  
  resource_group = module.resource_group
  environment    = "dev"
  address_space  = ["10.224.0.0/12"]  # Large address space for K8s pods/services
  
  subnets = {
    # Main subnet for Kubernetes nodes and pods
    kubernetes = {
      address_prefixes  = ["10.224.0.0/16"]
      service_endpoints = ["Microsoft.Storage", "Microsoft.ContainerRegistry", "Microsoft.KeyVault"]
      
      nsg_rules = {
        # Allow SSH for node management (restrict source as needed)
        allow_ssh = {
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "22"
          source_address_prefix      = "10.224.0.0/16"  # Only from within VNet
          destination_address_prefix = "*"
        }
        
        # Allow Kubernetes API Server
        allow_k8s_api = {
          priority                   = 110
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "6443"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }
        
        # Allow HTTP traffic to ingress
        allow_http = {
          priority                   = 120
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "80"
          source_address_prefix      = "Internet"
          destination_address_prefix = "*"
        }
        
        # Allow HTTPS traffic to ingress
        allow_https = {
          priority                   = 130
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "443"
          source_address_prefix      = "Internet"
          destination_address_prefix = "*"
        }
        
        # Allow Kubelet API
        allow_kubelet = {
          priority                   = 140
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "10250"
          source_address_prefix      = "10.224.0.0/16"
          destination_address_prefix = "*"
        }
        
        # Allow NodePort Services (if using NodePort)
        allow_nodeports = {
          priority                   = 150
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_ranges    = ["30000-32767"]
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }
        
        # Allow all outbound (K8s needs to pull images, etc.)
        allow_outbound = {
          priority                   = 100
          direction                  = "Outbound"
          access                     = "Allow"
          protocol                   = "*"
          source_port_range          = "*"
          destination_port_range     = "*"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }
      }
    }
  }
  
  # Custom tag for Kubernetes
  custom_tags = {
    workload = "kubernetes"
  }
}
