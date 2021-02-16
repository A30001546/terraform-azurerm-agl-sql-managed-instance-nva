# Creates subnets
# Documentation:
#   https://docs.microsoft.com/en-us/azure/sql-database/sql-database-managed-instance-determine-size-vnet-subnet

locals {
  
}
module "subnet_primary" {
  source                                         = "terraform.automation.agl.com.au/AGL/agl-subnet/azurerm"
  version                                        = "2.3.2"
  subnet_name                                    = var.subnet_name
  resource_group_name                            = var.mgmt_resource_group_name
  virtual_network_name                           = var.virtual_network_name
  address_prefix                                 = var.address_prefix // Picked the last Ips in the Vnet 10.9.19.128/25 to avoid overlaps
  delegation_name                                = "Microsoft.Sql/managedInstances"
  network_security_group_id                      = module.nsg_primary.id
  custom_route_table                             = true
  enforce_private_link_endpoint_network_policies = true
  route_table_id                                 = azurerm_route_table.route_primary.id
  delegation_actions                             = ["Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action", "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action", ]

 # depends_on = [module.nsg_primary,azurerm_route_table.route_primary]
}

module "subnet_secondary" {
  source                                         = "terraform.automation.agl.com.au/AGL/agl-subnet/azurerm"
  version                                        = "2.3.2"
  count                                          = local.ha_count
  subnet_name                                    = var.subnet_name
  resource_group_name                            = var.mgmt_resource_group_name
  virtual_network_name                           = var.virtual_network_name
  address_prefix                                 = var.address_prefix // Picked the last Ips in the Vnet 10.9.19.128/25 to avoid overlaps
  delegation_name                                = "Microsoft.Sql/managedInstances"
  network_security_group_id                      = module.nsg_secondary[count.index].id
  custom_route_table                             = true
  enforce_private_link_endpoint_network_policies = true
  route_table_id                                 = azurerm_route_table.route_secondary[count.index].id
  delegation_actions                             = ["Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action", "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action", ]
 # depends_on = [module.nsg_secondary,azurerm_route_table.route_secondary]
}