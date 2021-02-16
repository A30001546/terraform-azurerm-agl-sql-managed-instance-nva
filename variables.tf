variable "resource_group_name" {
  description = "The name of the resource group in which to create the Instance."
}

variable "location" {
  description = "Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
  default     = "australiasoutheast"
}

variable "storageSizeInGB" {
  description = "Storage size for instance in GB"
  default     = 256
  type        = number
}

variable "license_type" {
  description = "basePrice or licenseIncluded"
  default     = "licenseincluded"
}

variable "collation" {
  description = "The name of the collation. Changing this forces a new resource to be created."
  default     = "SQL_LATIN1_GENERAL_CP1_CI_AS"
}

variable "sku_name" {
  description = "The name of the SKU: BC_Gen5 or GP_Gen5"
  default     = "GP_Gen5"
}

variable "sku_edition" {
  description = "SKU edition, GeneralPurpose or BusinessCritical"
  default     = "GeneralPurpose"
}

variable "v_cores" {
  description = "number of vcores: https://docs.microsoft.com/en-us/azure/sql-database/sql-database-service-tiers-vcore"
  default     = 4
  type        = number
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map
}

variable "timezone" {
  description = "Timezone for managed instance UTC, 'AUS Eastern Standard Time' or 'E. Australia Standard Time'"
  default     = "UTC"
}

variable "name" {
  description = "Name of the managed instance, format '[name]'-mi), if not provided, a name would be gnerated."
  type        = string
  default     = null
}

variable "mgmt_resource_group_name" {
  description = "The name of the resourcegroup in which the subnet is intended to be provisioned, this is the same RG the vNet belongs to"
  default     = "management"
}

variable "nsg_name" {
  description = "The name for the primary network security group. Changing this forces a new resource to be created."
}

variable "network_watcher_name" {
  description = "The name of the primary Network Watcher. Changing this forces a new resource to be created."
}

variable "subnet_name" {
  description = "The name for the primary subnet that is being created, Changing this forces a new resource to be created."
}

variable "address_prefix" {
  description = "The primary address prefix os the subnet range in the format 10.10.20.0/24"
}

variable "virtual_network_name" {
  description = "The name of the primary virtual network to which to attach the subnet. Changing this forces a new resource to be created."
}

variable "dr_resource_group_name" {
  description = "The name of the secondary resource group in which to create the Instance."
}

variable "dr_subnet_name" {
  description = "The name for the secondary subnet that is being created, Changing this forces a new resource to be created."
  default     = null
}

variable "dr_virtual_network_name" {
  description = "The name of the secondary virtual network to which to attach the subnet. Changing this forces a new resource to be created."
  default     = null
}

variable "dr_address_prefix" {
  default     = null
  description = "The address prefix os the subnet range in the format 10.10.20.0/24"
}

variable "dr_network_watcher_name" {
  description = "The name of the secondary Network Watcher. Changing this forces a new resource to be created."
  default     = null
}

variable "dr_nsg_name" {
  default     = null
  description = "The name for the secondary network security group. Changing this forces a new resource to be created."
}

variable "ha_enabled" {
  description = "set to true to deploy resources across mutliple regions"
  default     = false
  type        = bool
}

variable "dr_location" {
  description = "Specifies the supported Azure location where the secondary resource exists. Changing this forces a new resource to be created."
  default     = "australiaeast"
}