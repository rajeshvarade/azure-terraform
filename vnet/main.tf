resource "azurerm_resource_group" "rg" {
  name     = "batch-20"
  location = "Central India"

   tags = {
    environment = "Production"
  }
}

resource "azurerm_network_security_group" "nsg" {
  name                = "batch20-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_virtual_network" "vnet" {
  name                = "batch20-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]

  subnet {
    name             = "subnet-app"
    address_prefix = "10.0.1.0/24"
  }

  subnet {
    name             = "subnet-db"
    address_prefix = "10.0.2.0/28"
    security_group   = azurerm_network_security_group.nsg.id
  }

  tags = {
    environment = "Production"
  }
}