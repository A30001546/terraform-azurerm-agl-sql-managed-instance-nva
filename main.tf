terraform {
  required_version = ">= 0.13"
}

locals {
  ha_count    = var.ha_enabled == true ? 1 : 0
  random_name = var.name == "" ? lower(random_string.name.result) : lower(var.name)
  sql_mi_env  = length(regexall("-production", lower(data.azurerm_subscription.current.display_name))) == 1 && length(regexall("-non", lower(data.azurerm_subscription.current.display_name))) == 0 ? "prod" : "nonprod"
  location    = var.location == "australiaeast" ? "ae" : (var.location == "australiasoutheast" ? "ause" : null)
  dr_location = var.dr_location == "australiaeast" ? "ae" : (var.dr_location == "australiasoutheast" ? "ause" : null)
}

data "azurerm_subscription" "current" {
}

resource "random_string" "name" {
  length  = 6
  upper   = false
  special = false
  number  = false
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "@"
}

resource "azurerm_template_deployment" "managed_instance-primary" {
  name                = format("%s-primary", random_string.name.result)
  resource_group_name = var.resource_group_name
  timeouts {
    create = "300m"
    delete = "300m"
  }
  template_body = <<DEPLOY
{
  "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
    "resources": [
        {
            "name": "${local.random_name}-mi",
            "type": "Microsoft.Sql/managedInstances",
            "apiVersion": "2019-06-01-preview",
            "identity": {
                "type": "SystemAssigned"
            },
            "location": "${var.location}",
            "sku": {
                "name": "${var.sku_name}"
            },
            "properties": {
                "administratorLogin": "${local.random_name}-admin",
                "administratorLoginPassword": "${random_password.password.result}",
                "subnetId": "${module.subnet_primary.id}",
                "storageSizeInGB": "${var.storageSizeInGB}",
                "vCores": "${var.v_cores}",
                "licenseType": "${var.license_type}",
                "hardwareFamily": "Gen5",
                "skuEdition": "${var.sku_edition}",
                "collation": "${var.collation}",
                "proxyOverride": "Redirect",
                "publicDataEndpointEnabled": "false",
                "timezoneId": "${var.timezone}"
            }
        }
    ],
     "outputs": {
      "instanceName": {
        "type": "string",
        "value": "${local.random_name}-mi"
    },
      "resourceID": {
          "type": "string",
          "value": "[resourceId('Microsoft.Sql/managedInstances', '${local.random_name}-mi')]"
      }
  }
}
DEPLOY

  deployment_mode = "Incremental"
  depends_on      = [module.subnet_primary]
}

resource "azurerm_template_deployment" "managed_instance-dr" {
  count               = local.ha_count
  name                = format("%s-dr", random_string.name.result)
  resource_group_name = var.resource_group_name
  timeouts {
    create = "300m"
    delete = "300m"
  }
  template_body = <<DEPLOY
{
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "resources": [
        {
            "name": "${local.random_name}-mi-dr",
            "type": "Microsoft.Sql/managedInstances",
            "apiVersion": "2019-06-01-preview",
            "identity": {
                "type": "SystemAssigned"
            },
            "location": "${var.dr_location}",
            "sku": {
                "name": "${var.sku_name}"
            },
            "properties": {
                "administratorLogin": "${local.random_name}-admin",
                "administratorLoginPassword": "${random_password.password.result}",
                "subnetId": "${module.subnet_secondary[count.index].id}",
                "storageSizeInGB": "${var.storageSizeInGB}",
                "vCores": "${var.v_cores}",
                "licenseType": "${var.license_type}",
                "hardwareFamily": "Gen5",
                "skuEdition": "${var.sku_edition}",
                "dnsZonePartner": "${replace(azurerm_template_deployment.managed_instance-primary.outputs.resourceID, format("resourceGroups/%s", var.resource_group_name), format("resourceGroups/%s", lower(var.resource_group_name)))}",
                "collation": "${var.collation}",
                "proxyOverride": "Redirect",
                "publicDataEndpointEnabled": "false",
                "timezoneId": "${var.timezone}"
            }
        }
    ]
}
DEPLOY

  deployment_mode = "Incremental"
  depends_on      = [azurerm_template_deployment.managed_instance-primary, module.subnet_secondary]
}
