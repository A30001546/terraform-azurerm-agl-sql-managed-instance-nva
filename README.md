# agl-sql-managed-instance-nva

Azure SQL managed Instance module

## Simple usage

  ```
  provider "azurerm" {
  version         = "~>2.0" // Provider version required to be 2.x
  subscription_id = "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
  features {}
}

  module "sql_instance" {
  source              = "terraform.automation.agl.com.au/AGL/agl-sql-instance/azurerm"
  location            = var.location
  resource_group_name = var.resource_group
  tags                = local.tags
  subnet_id           = module.subnet_ause.id
}
module "sql_instance_db" {
  source               = "terraform.automation.agl.com.au/AGL/agl-sql-instance-db/azurerm"
  location             = var.location
  resource_group_name  = var.resource_group_name
  managedInstance_name = module.sql_instance.name
  database_name        = "new-db"
}

module "subnet_ause" {
  source                    = "terraform.automation.agl.com.au/AGL/agl-subnet/azurerm"
  version                   = "2.0.0"
  subnet_name               = "${var.app_name}-${var.environment}-ause"
  resource_group_name       = var.mgmt_resource_group
  virtual_network_name      = var.virtual_network_name_ause
  address_prefix            = var.subnet_ause
  network_security_group_id = azurerm_network_security_group.nsg-ause.id
  delegation_name           = "Microsoft.Sql/managedInstances"
  route_table_id            = azurerm_route_table.UDR-ASE.id
}
```
**DEPLOY TIME WILL TAKE APPROX 4 HOURS - TERRAFORM AZURERM 2.0+ PROVIDER IS REQUIRED**

* Ensure you copy in the UDR\URD.tf file from this repo to your workspace and attach it to your subnet (contains both regions)
* Ensure you copy in the NSG\NSG.tf file from this repo to your workspace and attach it to your subnet (contains both regions)
* Subnets need to have this UDR attached
* Subnets need to Include the NSG rules defined in this repo, this can be combined with other rules if required.
* Subnets should be a minimum size of /27
* Subnets require the delegation to Microsoft.sql/managedInstances

A shared managed instance will be more cost effective than a one to one.

Dual instance geo redundancy is coming in a future release. Single instances have multiple redundancy measures, run on a multi node fault tolerant virtual cluster on the back end and a 99.99% SLA which is adequate for most workloads.

Deleting a managed instance can leave subnet's locked from being deleted or modified for up to 24 hours. Please ensure you have tested prior to deploy to avoid delays.

Database creation is optional depending on use cases and if management of DB via TFE is desired.

## To-do
Check this https://github.com/terraform-providers/terraform-provider-azurerm/issues/1747 to see the progres of terraform sql mi module
