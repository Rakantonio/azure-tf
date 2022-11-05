# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "arg" {
    name     = "arg-resources"
    location = "francecentral"
}

# Create a network security group
resource "azurerm_network_security_group" "ansg" {
    name                = "ansg-security-group"
    location            = azurerm_resource_group.arg.location
    resource_group_name = azurerm_resource_group.arg.name
}

#Create a network security group rule
resource "azurerm_network_security_rule" "ansgr" {
    name                        = "rules-network"
    priority                    = 100
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "22"
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
    resource_group_name         = azurerm_resource_group.arg.name
    network_security_group_name = azurerm_network_security_group.ansg.name
}

# Create multiple public ip resources
resource "azurerm_public_ip" "aip1" {
    name                = "public-ip1"
    resource_group_name = azurerm_resource_group.arg.name
    location            = azurerm_resource_group.arg.location
    allocation_method   = "Static"
}
resource "azurerm_public_ip" "aip2" {
    name                = "public-ip2"
    resource_group_name = azurerm_resource_group.arg.name
    location            = azurerm_resource_group.arg.location
    allocation_method   = "Static"
}
resource "azurerm_public_ip" "aip3" {
    name                = "public-ip3"
    resource_group_name = azurerm_resource_group.arg.name
    location            = azurerm_resource_group.arg.location
    allocation_method   = "Static"
}

# Create a virtual network for group 1
resource "azurerm_virtual_network" "vpc1" {
    name                = "vpc1-network"
    location            = azurerm_resource_group.arg.location
    resource_group_name = azurerm_resource_group.arg.name
    address_space       = [ "10.0.0.0/16" ]
}

# Create a virtual network for group 2
resource "azurerm_virtual_network" "vpc2" {
    name                = "vpc2-network"
    location            = azurerm_resource_group.arg.location
    resource_group_name = azurerm_resource_group.arg.name
    address_space       = [ "10.0.0.0/16" ]
}

# Create a subnet1
resource "azurerm_subnet" "as1" {
    name                 = "as-subnet1"
    resource_group_name  =  azurerm_resource_group.arg.name
    virtual_network_name = azurerm_virtual_network.vpc1.name
    address_prefixes     = [ "10.0.1.0/24" ]
}

# Create a subnet2
resource "azurerm_subnet" "as2" {
    name                 = "as-subnet2"
    resource_group_name  = azurerm_resource_group.arg.name
    virtual_network_name = azurerm_virtual_network.vpc2.name
    address_prefixes     = [ "10.0.2.0/24" ] 
}

# Create an interface1
resource "azurerm_network_interface" "vmNic1" {
    name                = "int1-nic"
    location            = azurerm_resource_group.arg.location
    resource_group_name = azurerm_resource_group.arg.name

    ip_configuration {
      name                          = "internal"
      subnet_id                     = azurerm_subnet.as1.id
      private_ip_address_allocation = "Dynamic"
      public_ip_address_id          = azurerm_public_ip.aip1.id
    }
}

# Create an interface2
resource "azurerm_network_interface" "vmNic2" {
    name                = "int2-nic"
    location            = azurerm_resource_group.arg.location
    resource_group_name = azurerm_resource_group.arg.name

    ip_configuration {
      name                          = "internal"
      subnet_id                     = azurerm_subnet.as1.id
      private_ip_address_allocation = "Dynamic"
      public_ip_address_id          = azurerm_public_ip.aip2.id
    }
}

# Create an interface3
resource "azurerm_network_interface" "vmNic3" {
    name                = "int3-nic"
    location            = azurerm_resource_group.arg.location
    resource_group_name = azurerm_resource_group.arg.name

    ip_configuration {
      name                          = "internal"
      subnet_id                     = azurerm_subnet.as2.id
      private_ip_address_allocation = "Dynamic"
      public_ip_address_id          = azurerm_public_ip.aip3.id
    }
}

#Create a first resource
resource "azurerm_linux_virtual_machine" "vm1" {
    name                    = "instance-1"
    resource_group_name     = azurerm_resource_group.arg.name
    location = azurerm_resource_group.arg.location
    size                    = "Standard_B1ls"
    admin_username          = "tp2"
    network_interface_ids   = [ 
            azurerm_network_interface.vmNic1.id,
        ]

    admin_ssh_key {
    username   = "tp2"
    public_key = file("~/.ssh/id_rsa.pub")
    }

    os_disk {
      caching              = "ReadWrite"
      storage_account_type = "Standard_LRS"
    }

    source_image_reference {
      publisher = "Canonical"
      offer     = "0001-com-ubuntu-server-focal"
      sku       = "20_04-lts-gen2"
      version   = "latest"
    }
}

#Create a second resource
resource "azurerm_linux_virtual_machine" "vm2" {
    name                  = "instance-2"
    resource_group_name   = azurerm_resource_group.arg.name
    location              = azurerm_resource_group.arg.location
    size                  = "Standard_B1ls"
    admin_username        = "tp2"
    network_interface_ids = [ 
            azurerm_network_interface.vmNic2.id,
        ]

    admin_ssh_key {
    username   = "tp2"
    public_key = file("~/.ssh/id_rsa.pub")
    }
    
    os_disk {
      caching               = "ReadWrite"
      storage_account_type  = "Standard_LRS"
    }

    source_image_reference {
      publisher = "Canonical"
      offer     = "0001-com-ubuntu-server-focal"
      sku       = "20_04-lts-gen2"
      version   = "latest"
    }
}

# Create a third resource
resource "azurerm_linux_virtual_machine" "vm3" {
    name                  = "instance-3"
    resource_group_name   = azurerm_resource_group.arg.name
    location              = azurerm_resource_group.arg.location
    size                  = "Standard_B1ls"
    admin_username        = "tp2"
    network_interface_ids = [ 
            azurerm_network_interface.vmNic3.id,
        ]
    
    admin_ssh_key {
    username   = "tp2"
    public_key = file("~/.ssh/id_rsa.pub")
    }

    os_disk {
      caching               = "ReadWrite"
      storage_account_type  = "Standard_LRS"
    }

    source_image_reference {
      publisher = "Canonical"
      offer     = "0001-com-ubuntu-server-focal"
      sku       = "20_04-lts-gen2"
      version   = "latest"
    }
}