variable "resource_group" {
  description = "The resource group object from the RG module"
  type = object({
    id       = string
    name     = string
    location = string
    tags     = map(string)
  })
}

variable "environment" {
  description = "Environment name"
  type        = string
  
  validation {
    condition     = contains(["acceptance", "development", "integration", "production" ], var.environment)
    error_message = "Environment must be one of: acceptance, development, integration, production"
  }
}

variable "address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  
  validation {
    condition     = length(var.address_space) > 0
    error_message = "At least one address space must be specified"
  }
  
  validation {
    condition = alltrue([
      for cidr in var.address_space : can(cidrhost(cidr, 0))
    ])
    error_message = "All address spaces must be valid CIDR blocks (e.g., 10.0.0.0/16)"
  }
}

variable "subnets" {
  description = "Map of subnets to create with their configurations"
  type = map(object({
    address_prefixes = list(string)
    service_endpoints = optional(list(string), [])
    delegation = optional(object({
      name = string
      service_delegation = object({
        name    = string
        actions = optional(list(string), [])
      })
    }))
    nsg_rules = optional(map(object({
      priority                   = number
      direction                  = string
      access                     = string
      protocol                   = string
      source_port_range          = optional(string, "*")
      destination_port_range     = optional(string)
      destination_port_ranges    = optional(list(string))
      source_address_prefix      = optional(string)
      source_address_prefixes    = optional(list(string))
      destination_address_prefix = optional(string)
      destination_address_prefixes = optional(list(string))
    })), {})
    route_table_routes = optional(map(object({
      address_prefix         = string
      next_hop_type          = string
      next_hop_in_ip_address = optional(string)
    })), {})
  }))
  default = {}
  
  validation {
    condition = alltrue([
      for subnet_key, subnet in var.subnets : alltrue([
        for cidr in subnet.address_prefixes : can(cidrhost(cidr, 0))
      ])
    ])
    error_message = "All subnet address prefixes must be valid CIDR blocks"
  }
  
  validation {
    condition = alltrue([
      for subnet_key, subnet in var.subnets : alltrue([
        for rule_key, rule in subnet.nsg_rules : 
          rule.priority >= 100 && rule.priority <= 4096
      ])
    ])
    error_message = "NSG rule priorities must be between 100 and 4096"
  }
  
  validation {
    condition = alltrue([
      for subnet_key, subnet in var.subnets : alltrue([
        for rule_key, rule in subnet.nsg_rules : 
          contains(["Inbound", "Outbound"], rule.direction)
      ])
    ])
    error_message = "NSG rule direction must be either 'Inbound' or 'Outbound'"
  }
  
  validation {
    condition = alltrue([
      for subnet_key, subnet in var.subnets : alltrue([
        for rule_key, rule in subnet.nsg_rules : 
          contains(["Allow", "Deny"], rule.access)
      ])
    ])
    error_message = "NSG rule access must be either 'Allow' or 'Deny'"
  }
  
  validation {
    condition = alltrue([
      for subnet_key, subnet in var.subnets : alltrue([
        for rule_key, rule in subnet.nsg_rules : 
          contains(["Tcp", "Udp", "Icmp", "*"], rule.protocol)
      ])
    ])
    error_message = "NSG rule protocol must be one of: 'Tcp', 'Udp', 'Icmp', '*'"
  }
  
  validation {
    condition = alltrue([
      for subnet_key, subnet in var.subnets : alltrue([
        for route_key, route in subnet.route_table_routes : 
          contains(["VirtualNetworkGateway", "VnetLocal", "Internet", "VirtualAppliance", "None"], route.next_hop_type)
      ])
    ])
    error_message = "Route next_hop_type must be one of: 'VirtualNetworkGateway', 'VnetLocal', 'Internet', 'VirtualAppliance', 'None'"
  }
}

variable "custom_tags" {
  description = "Custom tags specific to networking resources (merged with resource group tags)"
  type        = map(string)
  default     = {}
}
variable "enable_ddos_protection" {
  description = "Enable DDoS protection plan for the VNet"
  type        = bool
  default     = false
}

variable "ddos_protection_plan_id" {
  description = "ID of the DDoS protection plan (required if enable_ddos_protection is true)"
  type        = string
  default     = null
  
  validation {
    condition     = var.enable_ddos_protection == false || (var.enable_ddos_protection == true && var.ddos_protection_plan_id != null)
    error_message = "DDoS protection plan ID must be provided when DDoS protection is enabled"
  }
}

variable "dns_servers" {
  description = "Custom DNS servers for the VNet (uses Azure DNS if not specified)"
  type        = list(string)
  default     = []
  
  validation {
    condition = alltrue([
      for ip in var.dns_servers : can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", ip))
    ])
    error_message = "All DNS servers must be valid IPv4 addresses"
  }
}
