variable "resource_group_name" {
    description = "Name of the resource group"
    default     = "example-rg"
}

variable "location" {
    description = "Azure region"
    default     = "eastus2"
}

variable "vnet_name" {
    description = "Name of the virtual network"
    default     = "example-vnet"
}

variable "subnet_name" {
    description = "Name of the subnet"
    default     = "example-subnet"
}

variable "storage_account_name" {
    description = "Name of the storage account"
    default     = "tevinfexampleacct"
}

variable "key_vault_name" {
    description = "Name of the key vault"
    default     = "tevinf-keyvault1"
}

variable "private_endpoint_name" {
    description = "Name of the private endpoint"
    default     = "example-private-endpoint"
}

variable "Home_PIP" {
    description = "Home Public IP address for access"
  
}