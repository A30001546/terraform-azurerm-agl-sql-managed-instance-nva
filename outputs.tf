output "name" {
  value = jsondecode(azurerm_resource_group_template_deployment.sql_managed_instance_primary.output_content).instanceName.value
}

output "sqlpassword" {
  value = random_password.password.result
}


output "dr_sqlpassword" {
  value = random_password.password.result
}

output "dr_name" {
  value = var.ha_enabled ? jsondecode(azurerm_resource_group_template_deployment.sql_managed_instance_dr.*.output_content).instanceName.value : null
}

