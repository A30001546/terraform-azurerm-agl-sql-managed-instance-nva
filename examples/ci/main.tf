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

//Central-logging provider
provider "azurerm" {
  alias           = "enterprise-services-prod"
  version         = "~>2.0"                                // Provider version required to be 2.x
  subscription_id = "876e5b0d-b7fb-47d2-b709-9c78a560f389" // Enterprise-Services-Production
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



data "azurerm_resource_group" "workspace_sql_mi_testing" {
  name = "workspace-sql-mi-testing"
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
  virtual_network_name = "dphngcyl-ypsrbg"
  address_prefix       = "10.7.2.48/28"
  network_watcher_name = data.azurerm_network_watcher.mgmt_network_watcher_australiasoutheast.name
}