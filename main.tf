terraform {
  required_version = ">= 0.13"
}

locals {
  ha_count        = var.ha_enabled == true ? 1 : 0
  random_name     = var.name == "" ? lower(random_string.name.result) : lower(var.name)
  sql_mi_env      = length(regexall("-production", lower(data.azurerm_subscription.current.display_name))) == 1 && length(regexall("-non", lower(data.azurerm_subscription.current.display_name))) == 0 ? "prod" : "nonprod"
  location        = var.location == "australiaeast" ? "ae" : (var.location == "australiasoutheast" ? "ause" : null)
  dr_location     = var.dr_location == "australiaeast" ? "ae" : (var.dr_location == "australiasoutheast" ? "ause" : null)
  subscription_id = data.azurerm_subscription.current.subscription_id
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

resource "azurerm_resource_group_template_deployment" "sql_managed_instance_primary" {
  name                = format("%s-primary", random_string.name.result)
  resource_group_name = var.resource_group_name
  deployment_mode     = "Incremental"
  timeouts {
    create = "5h"
    delete = "5h"
  }
  template_content = <<TEMPLATE
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
        "type": "String",
        "value": "${local.random_name}-mi"
    },
      "resourceID": {
          "type": "String",
          "value": "[resourceId('Microsoft.Sql/managedInstances', '${local.random_name}-mi')]"
      }
  }
}
TEMPLATE
  depends_on = [module.subnet_primary, module.nsg_primary, azurerm_route_table.route_table_primary, azurerm_route.nva_route_primary, random_string.name, random_password.password, null_resource.az_cli_delete_sql_mi_virtual_cluster_primary]
}


resource "null_resource" "az_cli_delete_sql_mi_virtual_cluster_primary" {
  triggers = {
    subscription_id = data.azurerm_subscription.current.subscription_id
    resourceGroup = var.mgmt_resource_group_name
    subnetID = module.subnet_primary.id
  }

  provisioner "local-exec" {
    command = "echo tesing"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "chmod 500 ${path.module}/az_cli_delete_virtual_cluster.sh ;${path.module}/az_cli_delete_virtual_cluster.sh ${self.triggers.subscription_id} ${self.triggers.resourceGroup} \"${self.triggers.subnetID}\""
  }
  // explicit dependency
  depends_on = [module.subnet_primary, module.nsg_primary, azurerm_route_table.route_table_primary, azurerm_route.nva_route_primary]
}

// secondary sql-mi
resource "azurerm_resource_group_template_deployment" "sql_managed_instance_dr" {
  count               = local.ha_count
  name                = format("%s-dr", random_string.name.result)
  resource_group_name = var.dr_resource_group_name
  deployment_mode     = "Incremental"
  timeouts {
    create = "5h"
    delete = "5h"
  }
  template_content = <<TEMPLATE
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
                "dnsZonePartner": "${replace(jsondecode(azurerm_resource_group_template_deployment.sql_managed_instance_primary.output_content).resourceID.value, format("resourceGroups/%s", var.resource_group_name), format("resourceGroups/%s", lower(var.resource_group_name)))}",
                "collation": "${var.collation}",
                "proxyOverride": "Redirect",
                "publicDataEndpointEnabled": "false",
                "timezoneId": "${var.timezone}"
            }
        }
    ],
    "outputs": {
      "instanceName": {
        "type": "String",
        "value": "${local.random_name}-mi-dr"
    },
      "resourceID": {
          "type": "String",
          "value": "[resourceId('Microsoft.Sql/managedInstances', '${local.random_name}-mi-dr')]"
      }
  }
}
TEMPLATE

  depends_on = [azurerm_resource_group_template_deployment.sql_managed_instance_primary, module.subnet_secondary, module.nsg_secondary, azurerm_route_table.route_table_secondary, azurerm_route.nva_route_secondary, random_string.name, random_password.password, null_resource.az_cli_delete_sql_mi_virtual_cluster_secondary] #
}

resource "null_resource" "az_cli_delete_sql_mi_virtual_cluster_secondary" {
  count  = local.ha_count
  triggers = {
    subscription_id = data.azurerm_subscription.current.subscription_id
    resourceGroup = var.mgmt_resource_group_name
    subnetID = module.subnet_secondary[count.index].id
  }

  provisioner "local-exec" {
    command = "echo tesing"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "chmod 500 ${path.module}/az_cli_delete_virtual_cluster.sh ;${path.module}/az_cli_delete_virtual_cluster.sh ${self.triggers.subscription_id} ${self.triggers.resourceGroup} \"${self.triggers.subnetID}\""
  }
  // explicit dependency
  depends_on = [module.subnet_secondary, module.nsg_secondary, azurerm_route_table.route_table_secondary, azurerm_route.nva_route_secondary]
}




