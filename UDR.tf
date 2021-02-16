locals {
  route_config = {
    australiasoutheast_prod = {
      name                   = "ase_prod_nva_route" //check the name?
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.30.2.6"
    },
    australiaeast_prod = {
      name                   = "ae_prod_nva_route"
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.40.2.6"
    },
    australiasoutheast_nonprod = {
      name                   = "ase_nonprod_nva_route"
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.30.3.6"
    },
    australiaeast_nonprod = {
      name                   = "ae_nonprod_nva_route"
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.40.3.6"
    }
  }
}


resource "azurerm_route_table" "route_primary" {
  #count                         = local.sql_mi_env == "prod" && var.location == "australiasoutheast" ? 1 : 0
  name                          = "agl-sql-mi-primary_route"
  resource_group_name           = var.resource_group_name
  location                      = var.location
  disable_bgp_route_propagation = true
  tags                          = var.tags

  route {
    name                   = local.route_config[join("_", [var.location, local.sql_mi_env])].name
    address_prefix         = local.route_config[join("_", [var.location, local.sql_mi_env])].address_prefix
    next_hop_type          = local.route_config[join("_", [var.location, local.sql_mi_env])].next_hop_type
    next_hop_in_ip_address = local.route_config[join("_", [var.location, local.sql_mi_env])].next_hop_in_ip_address
  }
}

resource "azurerm_route_table" "route_secondary" {
  count                         = local.ha_count
  name                          = "agl-sql-mi-secondary_route"
  resource_group_name           = var.resource_group_name
  location                      = var.dr_location
  disable_bgp_route_propagation = true
  tags                          = var.tags

  route {
    name                   = local.route_config[join("_", [var.dr_location, local.sql_mi_env])].name
    address_prefix         = local.route_config[join("_", [var.dr_location, local.sql_mi_env])].address_prefix
    next_hop_type          = local.route_config[join("_", [var.dr_location, local.sql_mi_env])].next_hop_type
    next_hop_in_ip_address = local.route_config[join("_", [var.dr_location, local.sql_mi_env])].next_hop_in_ip_address
  }
}
