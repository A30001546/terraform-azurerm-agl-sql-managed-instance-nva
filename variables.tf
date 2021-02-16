variable "resource_group_name" {
  description = "The name of the resource group in which to create the Instance."
}
variable "location" {
  description = "Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
  default     = "australiasoutheast"
}
variable "dr_location" {
  description = "Specifies the supported Azure location where the secondary resource exists. Changing this forces a new resource to be created."
  default     = "australiaeast"
}

variable "storageSizeInGB" {
  description = "Storage size for instance in GB"
  default     = 256
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
variable "ha_enabled" {
  description = "true or false value to deploy across mutliple region"
  default     = false
}
variable "v_cores" {
  description = "number of vcores: https://docs.microsoft.com/en-us/azure/sql-database/sql-database-service-tiers-vcore"
  default     = 4
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
  default     = ""
}

variable "mgmt_resource_group_name" {
  description = "The name of the resourcegroup in which the subnet is intended to be provisioned, this is the same RG the vNet belongs to"
  default     = "management"
}



// need to writeup the description

//nsg
variable "nsg_name" {
}

variable "dr_nsg_name" {
  default = null

}

variable "network_watcher_name" {
  
}

variable "dr_network_watcher_name" {
  default = null
  
}


// Subnet 


variable "subnet_name" {
  description = "The name for the new subnet that is being created"
}

variable "address_prefix" {
  description = "The address prefix os the subnet range in the format 10.10.20.0/24"
}

variable "virtual_network_name" {

}

variable "custom_route_table" {
  default     = true
  description = "if a route table is required then this must be set to true, this flag is used to only activate this when needed"
}



variable "dr_subnet_name" {
  default = null

}

variable "dr_virtual_network_name" {
  default = null

}

variable "dr_address_prefix" {
  default = null

}

variable "dr_custom_route_table" {
  default     = true
  description = "if a route table is required then this must be set to true, this flag is used to only activate this when needed"
}

