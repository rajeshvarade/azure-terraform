resource "azurerm_resource_group" "rg" {
  name     = "rg-rajesh"
  location = "Central India"

   tags = {
    environment = "Production"
  }
}

resource "azurerm_network_security_group" "nsg" {
  name                = "rajesh-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_virtual_network" "vnet" {
  name                = "rajesh-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
/*
  subnet {
    name             = "subnet-app"
    address_prefix = "10.0.1.0/24"
  }

  subnet {
    name             = "subnet-db"
    address_prefix = "10.0.2.0/28"
    security_group   = azurerm_network_security_group.nsg.id
  }
*/
}

# Subnet
# ----------------------------
resource "azurerm_subnet" "subnet-app" {
  name                 = "subnet-app"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}
 
resource "azurerm_subnet" "subnet-db" {
  name                 = "subnet-db"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}
# Allow SSH
resource "azurerm_network_security_rule" "ssh" {
  name                        = "Allow-SSH"
  priority                    = 300
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

# Associate NSG to subnet
resource "azurerm_subnet_network_security_group_association" "nsg-assoc" {
  subnet_id                 = azurerm_subnet.subnet-app.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}
 
# Public IP
# ----------------------------
resource "azurerm_public_ip" "pip" {
  name                = "pip-rajesh"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"

  sku = "Standard"
}

# Network Interface
# ----------------------------
resource "azurerm_network_interface" "nic" {
  name                = "nic-rajesh"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
 
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet-app.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

# Linux Virtual Machine (Password Auth)
# ----------------------------
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "vm-rajesh"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_D2s_v3"
  admin_username      = "adminuser"
 
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]
 
  disable_password_authentication = false
  admin_password                  = "rajesh@12345" # must be strong
 
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
 
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

  tags = {
    environment = "Production"
  }
}