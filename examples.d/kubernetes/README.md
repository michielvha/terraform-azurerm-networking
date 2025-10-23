# Kubernetes Networking Example

This example creates a **simple, production-ready network** for hosting a Kubernetes cluster (AKS or self-managed).

## What Gets Created

- **1 Virtual Network** - 10.224.0.0/12 (large address space for pods and services)
- **1 Subnet** - 10.224.0.0/16 for Kubernetes nodes and pods
- **1 Network Security Group** with rules for:
  - ✅ Kubernetes API Server (port 6443)
  - ✅ HTTP/HTTPS ingress traffic (ports 80/443)
  - ✅ SSH for node management (port 22, internal only)
  - ✅ Kubelet API (port 10250)
  - ✅ NodePort range (30000-32767)
  - ✅ All outbound traffic (for image pulls, etc.)
- **Service Endpoints** for:
  - Azure Container Registry (for pulling images)
  - Azure Storage (for persistent volumes)
  - Azure Key Vault (for secrets)

## Architecture

```
Internet
   ↓
[Load Balancer] → HTTP/HTTPS (80/443)
   ↓
[Kubernetes Subnet] (10.224.0.0/16)
   ├── K8s API Server (6443)
   ├── Kubelet (10250)
   ├── NodePorts (30000-32767)
   └── Pods & Services
```

## Usage

### 1. Basic Deployment

```bash
# Update the resource group module source if needed
terraform init
terraform plan
terraform apply
```

### 2. Use with Azure Kubernetes Service (AKS)

After deploying this network, create your AKS cluster using the subnet:

```hcl
resource "azurerm_kubernetes_cluster" "main" {
  name                = "my-aks-cluster"
  location            = module.resource_group.location
  resource_group_name = module.resource_group.resource_group_name
  dns_prefix          = "myaks"
  
  default_node_pool {
    name           = "default"
    node_count     = 3
    vm_size        = "Standard_D2s_v3"
    vnet_subnet_id = module.networking.subnet_ids["kubernetes"]
  }
  
  network_profile {
    network_plugin = "azure"
    service_cidr   = "10.240.0.0/16"
    dns_service_ip = "10.240.0.10"
  }
  
  identity {
    type = "SystemAssigned"
  }
}
```

### 3. Use with Self-Managed Kubernetes

Deploy your Kubernetes VMs into the `kubernetes` subnet. The NSG rules are already configured for:
- Master node communication
- Worker node communication
- External access to services

## Network Configuration

### Address Spaces

- **VNet**: `10.224.0.0/12` - Provides ~1M IP addresses
- **Kubernetes Subnet**: `10.224.0.0/16` - Provides ~65K IPs for nodes and pods

This is sufficient for:
- Large number of pods
- Multiple node pools
- Pod-to-pod networking
- Service IPs

### Why This Address Range?

- `10.224.0.0/12` is recommended for AKS by Microsoft
- Avoids conflicts with common on-premises networks
- Large enough for horizontal scaling
- Follows Azure best practices

## Security Considerations

### Current NSG Rules

✅ **Allowed Inbound:**
- Kubernetes API (6443) from anywhere - *Consider restricting to specific IPs*
- HTTP/HTTPS (80/443) from Internet
- SSH (22) from VNet only
- Kubelet (10250) from VNet only
- NodePorts (30000-32767) from anywhere

✅ **Allowed Outbound:**
- All traffic (required for image pulls, updates, etc.)

### Security Hardening (Optional)

To improve security, update `main.tf`:

1. **Restrict API Server Access:**
```hcl
allow_k8s_api = {
  priority                   = 110
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_range     = "6443"
  source_address_prefix      = "YOUR_OFFICE_IP/32"  # Restrict to your IP
  destination_address_prefix = "*"
}
```

2. **Restrict SSH Access:**
```hcl
allow_ssh = {
  priority                   = 100
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_range     = "22"
  source_address_prefix      = "YOUR_BASTION_SUBNET"  # Use bastion host
  destination_address_prefix = "*"
}
```

3. **Disable NodePorts if using LoadBalancer:**
```hcl
# Remove or deny the allow_nodeports rule if you only use LoadBalancer services
```

## Next Steps

After deploying this network:

1. **Deploy AKS** using the subnet ID from outputs
2. **Configure kubectl** to connect to your cluster
3. **Install Ingress Controller** (NGINX, Traefik, etc.)
4. **Set up cert-manager** for SSL certificates
5. **Configure Azure CNI** or Kubenet networking

## Cost Considerations

- **VNet**: Free
- **Subnet**: Free
- **NSG**: Free
- **Service Endpoints**: Free

You only pay for the resources you deploy INTO this network (VMs, AKS cluster, Load Balancers, etc.)

## Customization

### Use Smaller Address Space

If you don't need many pods:

```hcl
address_space = ["10.0.0.0/16"]
subnets = {
  kubernetes = {
    address_prefixes = ["10.0.0.0/20"]  # ~4K IPs
    # ...
  }
}
```

### Add Application Gateway Subnet

For Application Gateway Ingress Controller (AGIC):

```hcl
subnets = {
  kubernetes = { ... }
  
  appgw = {
    address_prefixes = ["10.224.1.0/24"]
    # Application Gateway specific NSG rules...
  }
}
```

## Troubleshooting

### Pods can't pull images
- Verify service endpoint for Container Registry is enabled
- Check outbound NSG rules allow HTTPS (443)

### Can't access Kubernetes API
- Check NSG rule for port 6443
- Verify source IP is allowed

### Services not accessible
- Check LoadBalancer is created
- Verify NSG allows traffic on service ports
- Check NodePort range if using NodePort services

## Reference

- [AKS Network Concepts](https://learn.microsoft.com/azure/aks/concepts-network)
- [AKS Best Practices](https://learn.microsoft.com/azure/aks/best-practices)
- [Azure CNI Networking](https://learn.microsoft.com/azure/aks/configure-azure-cni)
