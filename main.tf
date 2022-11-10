# Create a resource group
resource "azurerm_resource_group" "arg" {
    name     = var.rg_name
    location = var.deploy_location
}

# Create a network security group
resource "azurerm_network_security_group" "ansg" {
    name                = var.nsg_name
    location            = var.deploy_location
    resource_group_name = var.rg_name
    depends_on          = [
      azurerm_resource_group.arg
    ]
}

#Create a network security group rule
resource "azurerm_network_security_rule" "ansr" {
    name                        = "rules-network"
    priority                    = 100
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "22"
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
    resource_group_name         = var.rg_name
    network_security_group_name = var.nsg_name
    depends_on                  = [
      azurerm_network_security_group.ansg
    ]
}

# Create multiple public ip resources
resource "azurerm_public_ip" "aip" {
    count               = 4
    name                = "public-ip-${count.index + 1}"
    resource_group_name = var.rg_name
    location            = var.deploy_location
    allocation_method   = "Dynamic"
    depends_on          = [
      azurerm_resource_group.arg
    ]
}

# Create a public ip from different region
resource "azurerm_public_ip" "aipr2" {
    name                = "public-ip-r2"
    resource_group_name = var.rg_name
    location            = "northeurope"
    allocation_method   = "Static"
    sku                 = "Standard"
    depends_on          = [
      azurerm_resource_group.arg
    ]
}


# Create a virtual network for group 
resource "azurerm_virtual_network" "vpc" {
    count               = 2
    name                = "vpc-${count.index + 1}-network"
    location            = var.deploy_location
    resource_group_name = var.rg_name
    address_space       = [ "10.0.0.0/16" ]
}

# Create a subnet1
resource "azurerm_subnet" "as1" {
    name                 = "as-subnet1"
    resource_group_name  =  var.rg_name
    virtual_network_name = azurerm_virtual_network.vpc[0].name
    address_prefixes     = [ "10.0.1.0/24" ]
}

# Create a subnet2
resource "azurerm_subnet" "as2" {
    name                 = "as-subnet2"
    resource_group_name  = var.rg_name
    virtual_network_name = azurerm_virtual_network.vpc[1].name
    address_prefixes     = [ "10.0.2.0/24" ] 
}

# Create an interface1
resource "azurerm_network_interface" "vmNic1" {
    name                = "int1-nic"
    location            = var.deploy_location
    resource_group_name = var.rg_name
    ip_configuration {
      name                          = "internal"
      subnet_id                     = azurerm_subnet.as1.id
      private_ip_address_allocation = "Dynamic"
      public_ip_address_id          = azurerm_public_ip.aip[0].id
    }
}

# Create an interface2
resource "azurerm_network_interface" "vmNic2" {
    name                = "int2-nic"
    location            = var.deploy_location
    resource_group_name = var.rg_name

    ip_configuration {
      name                          = "internal"
      subnet_id                     = azurerm_subnet.as1.id
      private_ip_address_allocation = "Dynamic"
      public_ip_address_id          = azurerm_public_ip.aip[1].id
    }
}

# Create an interface3
resource "azurerm_network_interface" "vmNic3" {
    name                = "int3-nic"
    location            = var.deploy_location
    resource_group_name = var.rg_name

    ip_configuration {
      name                          = "internal"
      subnet_id                     = azurerm_subnet.as2.id
      private_ip_address_allocation = "Dynamic"
      public_ip_address_id          = azurerm_public_ip.aip[2].id
    }
}

#Create a first resource
resource "azurerm_linux_virtual_machine" "vm1" {
    name                    = "instance-1"
    resource_group_name     = var.rg_name
    location                = var.deploy_location
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
    resource_group_name   = var.rg_name
    location              = var.deploy_location
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
    resource_group_name   = var.rg_name
    location              = var.deploy_location
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


resource "azurerm_nat_gateway" "ang" {
  name                = "nat-gateway-resource"
  location            = azurerm_public_ip.aipr2.location
  resource_group_name = var.rg_name
  sku_name            = "Standard"
  depends_on          = [
    azurerm_resource_group.arg
  ]
}

resource "azurerm_nat_gateway_public_ip_association" "angpia" {
  nat_gateway_id       = azurerm_nat_gateway.ang.id
  public_ip_address_id = azurerm_public_ip.aipr2.id
}