variable "resource_group_name" {
  description = "Name of the resource group"
  default     = "hastings"
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

variable "private_endpoint_name" {
  description = "Name of the private endpoint"
  default     = "example-private-endpoint"
}

variable "Home_PIP" {
  description = "Home Public IP address for access"

}
variable "user1_object_id" {
  description = "Object ID of the my personal user"

}
