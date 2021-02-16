# Create network security group rules 
# Documentation: 
#   https://docs.microsoft.com/en-us/azure/sql-database/sql-database-managed-instance-connectivity-architecture#mandatory-inbound-security-rules 
#   https://docs.microsoft.com/en-us/azure/sql-database/sql-database-managed-instance-find-management-endpoint-ip-address 
#   https://docs.microsoft.com/en-us/azure/sql-database/sql-database-managed-instance-management-endpoint-verify-built-in-firewall
#   https://docs.microsoft.com/en-us/azure/sql-database/sql-database-managed-instance-connectivity-architecture#mandatory-outbound-security-rules 
#   https://docs.microsoft.com/en-us/azure/sql-database/sql-database-connectivity-architecture#connection-policy 
#   https://docs.microsoft.com/en-us/azure/sql-database/sql-database-auto-failover-group#enabling-geo-replication-between-managed-instances-and-their-vnets 

provider "azurerm" {
  alias           = "enterprise-services-prod"
  version         = "~>2.0"                                // Provider version required to be 2.x
  subscription_id = "876e5b0d-b7fb-47d2-b709-9c78a560f389" // Enterprise-Services-Production
  features {}
}

module "nsg_primary" {
  source               = "terraform.automation.agl.com.au/AGL/agl-nsg/azurerm"
  name                 = var.nsg_name
  resource_group_name  = var.resource_group_name
  location             = var.location
  tags                 = var.tags
  network_watcher_name = var.network_watcher_name

  providers = {
    azurerm.central_logging = azurerm.enterprise-services-prod
  }
}


// NSG for DR
module "nsg_secondary" {
  source               = "terraform.automation.agl.com.au/AGL/agl-nsg/azurerm"
  count                = local.ha_count
  name                 = var.dr_nsg_name
  resource_group_name  = var.resource_group_name
  location             = var.dr_location
  tags                 = var.tags
  network_watcher_name = var.dr_network_watcher_name

  providers = {
    azurerm.central_logging = azurerm.enterprise-services-prod
  }
}