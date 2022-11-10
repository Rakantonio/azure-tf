# Create a variable for location
variable "deploy_location" {
  type = string
  default = "francecentral"
  description = "The Azure Region in which all resources should be created"
}

# Create a variable for resource group
variable "rg_name" {
  type = string
  default = "arg-resources"
  description = "Name of the Resource group in which to deploy storage"
}

# Create a variable for a network security group
variable "nsg_name" {
  type = string
  default = "ansg-security-group"
}