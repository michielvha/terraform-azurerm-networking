# Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = "${local.resource_prefix}-vnet"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  address_space       = var.address_space
  dns_servers         = length(var.dns_servers) > 0 ? var.dns_servers : null
  tags                = local.merged_tags

  dynamic "ddos_protection_plan" {
    for_each = var.enable_ddos_protection ? [1] : []
    content {
      id     = var.ddos_protection_plan_id
      enable = true
    }
  }
}

# Subnets
resource "azurerm_subnet" "subnets" {
  for_each = var.subnets

  name                 = "${local.resource_prefix}-${each.key}-subnet"
  resource_group_name  = var.resource_group.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = each.value.address_prefixes
  service_endpoints    = each.value.service_endpoints

  dynamic "delegation" {
    for_each = each.value.delegation != null ? [each.value.delegation] : []
    content {
      name = delegation.value.name
      service_delegation {
        name    = delegation.value.service_delegation.name
        actions = delegation.value.service_delegation.actions
      }
    }
  }
}

# Network Security Groups
resource "azurerm_network_security_group" "subnets" {
  for_each = var.subnets

  name                = "${local.resource_prefix}-${each.key}-nsg"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  tags                = local.merged_tags
}

# Network Security Rules
resource "azurerm_network_security_rule" "nsg_rules" {
  for_each = local.nsg_rules

  name                         = each.value.rule_name
  priority                     = each.value.priority
  direction                    = each.value.direction
  access                       = each.value.access
  protocol                     = each.value.protocol
  source_port_range            = each.value.source_port_range
  destination_port_range       = each.value.destination_port_range
  destination_port_ranges      = each.value.destination_port_ranges
  source_address_prefix        = each.value.source_address_prefix
  source_address_prefixes      = each.value.source_address_prefixes
  destination_address_prefix   = each.value.destination_address_prefix
  destination_address_prefixes = each.value.destination_address_prefixes
  resource_group_name          = var.resource_group.name
  network_security_group_name  = azurerm_network_security_group.subnets[each.value.subnet_key].name
}

# Associate NSGs with Subnets
resource "azurerm_subnet_network_security_group_association" "subnets" {
  for_each = var.subnets

  subnet_id                 = azurerm_subnet.subnets[each.key].id
  network_security_group_id = azurerm_network_security_group.subnets[each.key].id
}

# Route Tables
resource "azurerm_route_table" "subnets" {
  for_each = local.subnets_with_routes

  name                = "${local.resource_prefix}-${each.key}-rt"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  tags                = local.merged_tags
}

# Routes
resource "azurerm_route" "routes" {
  for_each = local.routes

  name                   = each.value.route_name
  resource_group_name    = var.resource_group.name
  route_table_name       = azurerm_route_table.subnets[each.value.subnet_key].name
  address_prefix         = each.value.address_prefix
  next_hop_type          = each.value.next_hop_type
  next_hop_in_ip_address = each.value.next_hop_in_ip_address
}

# Associate Route Tables with Subnets
resource "azurerm_subnet_route_table_association" "subnets" {
  for_each = local.subnets_with_routes

  subnet_id      = azurerm_subnet.subnets[each.key].id
  route_table_id = azurerm_route_table.subnets[each.key].id
}