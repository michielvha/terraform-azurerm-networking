# 🚀 Quick Start: Kubernetes Network

This example creates a **production-ready network for Kubernetes in Azure** - ready to use in ~5 minutes!

## What You Get

```
✅ VNet: 10.224.0.0/12 (1M IPs for massive scaling)
✅ Subnet: 10.224.0.0/16 (65K IPs for nodes & pods)
✅ Pre-configured NSG with all K8s ports
✅ Service endpoints (ACR, Storage, Key Vault)
✅ Automatic tag inheritance from RG module
```

## Deploy in 3 Steps

### 1️⃣ Clone and Navigate
```bash
cd examples/kubernetes
```

### 2️⃣ Update Resource Group Module Source
Edit `main.tf` line 5 to point to your RG module location

### 3️⃣ Deploy
```bash
terraform init
terraform plan
terraform apply
```

## Use with AKS

After network is created, deploy your AKS cluster:

```hcl
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "my-aks"
  location            = module.resource_group.location
  resource_group_name = module.resource_group.resource_group_name
  dns_prefix          = "myaks"
  
  default_node_pool {
    name           = "default"
    node_count     = 3
    vm_size        = "Standard_D2s_v3"
    vnet_subnet_id = module.networking.subnet_ids["kubernetes"]  # ← Use this!
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

## What's Included in NSG

| Port(s) | Protocol | Purpose | Source |
|---------|----------|---------|--------|
| 22 | TCP | SSH (node management) | VNet only |
| 6443 | TCP | Kubernetes API | Anywhere* |
| 80/443 | TCP | HTTP/HTTPS ingress | Internet |
| 10250 | TCP | Kubelet API | VNet only |
| 30000-32767 | TCP | NodePort services | Anywhere |
| All | All | Outbound (image pulls) | Any |

*Consider restricting to your office IP for security

## Outputs Available

```hcl
module.networking.subnet_ids["kubernetes"]      # Use for AKS vnet_subnet_id
module.networking.vnet_id                       # VNet ID
module.networking.nsg_ids["kubernetes"]         # NSG ID
```

## Cost

**Network components: $0/month** (VNet, Subnet, NSG are free)

You only pay for what you deploy INTO the network (AKS cluster, VMs, Load Balancers, etc.)

## Security Hardening

**Before production**, update these rules in `main.tf`:

1. **Restrict API Server** (line 35):
   ```hcl
   source_address_prefix = "YOUR_OFFICE_IP/32"  # Not "*"
   ```

2. **Use Bastion for SSH** (line 25):
   ```hcl
   source_address_prefix = "YOUR_BASTION_SUBNET"  # Not VNet-wide
   ```

## Next Steps

1. ✅ Deploy this network
2. ✅ Create AKS cluster using the subnet
3. ✅ Install ingress controller (NGINX/Traefik)
4. ✅ Set up cert-manager for SSL
5. ✅ Deploy your apps!

## Troubleshooting

**Pods can't pull images?**
→ Check service endpoint for Container Registry is enabled

**Can't access API?**
→ Verify NSG rule for port 6443 allows your IP

**Services not accessible?**
→ Check LoadBalancer created and NSG allows traffic

---

**Need help?** Check the full [README.md](./README.md) for detailed docs!
