output "name" {
  value = azurerm_template_deployment.managed_instance-primary.outputs.instanceName
}

output "sqlpassword" {
  value = random_password.password.result
}

output "resourceID" {
  value = azurerm_template_deployment.managed_instance-primary.outputs.resourceID
}

output "dr_sqlpassword" {
  value = random_password.password.result
}

/*
output "dr_name" {
  value = var.ha_enabled ? element(azurerm_template_deployment.managed_instance-dr.*.outputs.instanceName,0) : null
}

output "dr_resourceID" {
  value = var.ha_enabled ? element(azurerm_template_deployment.managed_instance-dr.*.outputs.resourceID,0) : null
}
*/

