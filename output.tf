output "sqlpassword" {
  value = random_password.password.result
}

output "name" {
  value = azurerm_template_deployment.managed_instance-primary.outputs.instanceName
}

