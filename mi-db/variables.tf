variable "resource_group_name" {
  description = "The name of the resource group in which to create the database. This must be the same as manged Instance resource group."
}
variable "location" {
  description = "Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
  default     = "australiasoutheast"
}
variable "collation" {
  description = "The name of the collation. Changing this forces a new resource to be created."
  default     = "SQL_LATIN1_GENERAL_CP1_CI_AS"
}
variable "managedInstance_name" {
  description = "The name of the SQL Managed Instance."
}
variable "database_name" {
  description = "The name of the database."
}