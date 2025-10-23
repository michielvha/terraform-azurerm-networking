locals {
  resource_prefix = "lz-${var.environment}"

  # Merge resource group tags with custom networking tags
  merged_tags = merge(
    var.resource_group.tags,
    var.custom_tags,
    {
      managed-by = "terraform"
    }
  )

  # Flatten NSG rules for easier iteration
  nsg_rules = merge([
    for subnet_key, subnet in var.subnets : {
      for rule_key, rule in subnet.nsg_rules : "${subnet_key}-${rule_key}" => {
        subnet_key                   = subnet_key
        rule_name                    = rule_key
        priority                     = rule.priority
        direction                    = rule.direction
        access                       = rule.access
        protocol                     = rule.protocol
        source_port_range            = rule.source_port_range
        destination_port_range       = rule.destination_port_range
        destination_port_ranges      = rule.destination_port_ranges
        source_address_prefix        = rule.source_address_prefix
        source_address_prefixes      = rule.source_address_prefixes
        destination_address_prefix   = rule.destination_address_prefix
        destination_address_prefixes = rule.destination_address_prefixes
      }
    }
  ]...)

  # Flatten routes for easier iteration
  routes = merge([
    for subnet_key, subnet in var.subnets : {
      for route_key, route in subnet.route_table_routes : "${subnet_key}-${route_key}" => {
        subnet_key             = subnet_key
        route_name             = route_key
        address_prefix         = route.address_prefix
        next_hop_type          = route.next_hop_type
        next_hop_in_ip_address = route.next_hop_in_ip_address
      }
    }
  ]...)

  # Determine which subnets need route tables
  subnets_with_routes = {
    for subnet_key, subnet in var.subnets : subnet_key => subnet
    if length(subnet.route_table_routes) > 0
  }
}