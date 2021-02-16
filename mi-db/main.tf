resource "azurerm_template_deployment" "managed_instance-db" {
  name                = "${var.managedInstance_name}-${var.database_name}"
  resource_group_name = var.resource_group_name

  template_body = <<DEPLOY
{
  "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
    "resources": [
        {
            "type": "Microsoft.Sql/managedInstances/databases",
            "apiVersion": "2019-06-01-preview",
            "name": "${var.managedInstance_name}/${var.database_name}",
            "location": "${var.location}",
            "properties": {
                "collation": "${var.collation}"
            }
        }
    ]
}
DEPLOY

  deployment_mode = "Incremental"
}
