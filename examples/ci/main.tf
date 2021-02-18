terraform {
  backend "remote" {
    hostname     = "terraform.automation.agl.com.au"
    organization = "AGL"
    workspaces {
      name = "workspace-sql-mi-testing"
    }
  }
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
    null = {
      source = "hashicorp/null"
    }
    tls = {
      source = "hashicorp/tls"
    }
    random = {
      source = "hashicorp/random"
    }
  }
  required_version = ">= 0.13"
}


provider "azurerm" {
  version         = "~>2.0"                                // Provider version required to be 2.x
  subscription_id = "83118407-40f2-4867-a0cd-6db86b5caf4d" // Automation-Testing-Nonproduction
  features {}
}

locals {
  pipeline = "pipeline-module-azurerm-sql-database"
  tags = {
    BusinessOwner  = "Owen Rapose"
    TechnicalOwner = "Daniel Hermans"
    CostCode       = "C-INF-000067-08-09-02"
    Project        = "Automation"
  }
}

/*
resource "random_pet" "resource-group" {
  prefix = "${local.pipeline}"
  length = 1
}

resource "azurerm_resource_group" "pipeline" {
  location = "australiaeast"
  name     = "${random_pet.resource-group.id}"
  tags     = "${local.tags}"
}
*/

data "azurerm_network_watcher" "mgmt_network_watcher_australiaeast" {
  name                = "dphngcylae"
  resource_group_name = "management"
}

data "azurerm_network_watcher" "mgmt_network_watcher_australiasoutheast" {
  name                = "dphngcylase"
  resource_group_name = "management"
}

module "sql-mi" {
  source               = "../../"
  name                 = "testing-sql-mi"
  resource_group_name  = "workspace-sql-mi-testing"
  location             = "australiasoutheast"
  collation            = "Latin1_General_CI_AS"
  license_type         = "LicenseIncluded"
  sku_name             = "GP_Gen5"
  storageSizeInGB      = "512"
  timezone             = "AUS Eastern Standard Time"
  v_cores              = "4"
  tags                 = local.tags
  nsg_name             = "sql-mi-testing-nsg-01"
  subnet_name          = "sql-mi-testing-subnet-01"
  virtual_network_name = "dphngcyl-pdhaqq"
  address_prefix       = "10.6.1.64/28"
  dr_resource_group_name = "workspace-sql-mi-testing"
  network_watcher_name = data.azurerm_network_watcher.mgmt_network_watcher_australiasoutheast.name
  //dr variables
  dr_subnet_name ="sql-mi-testing-dr-subnet-01"
  dr_virtual_network_name = "dphngcyl-tvyxyd"
  dr_address_prefix = "10.9.19.160/28"
  dr_network_watcher_name = data.azurerm_network_watcher.mgmt_network_watcher_australiaeast.name
  dr_nsg_name = "sql-mi-testing-dr-nsg-01"
  ha_enabled = true
  dr_location = "australiaeast"
}

output "name" {
  value = module.sql-mi.name
}

output "pass" {
  value = module.sql-mi.sqlpassword

}

output "dr_pass" {
  value = module.sql-mi.dr_sqlpassword
}

output "dr_name" {
  value = module.sql-mi.dr_name
}

