resource "azurerm_resource_group" "stgac-batch20" {
  name     = "stgac-batch20"
  location = "Central India"
}

resource "azurerm_storage_account" "stgac-batch20-storage" {
  name                     = "rajesh239testingstorage"
  resource_group_name      = azurerm_resource_group.stgac-batch20.name
  location                 = azurerm_resource_group.stgac-batch20.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  access_tier              = "Hot"

  depends_on = [azurerm_resource_group.stgac-batch20]

  
  tags = {
    environment = "staging"
  }
}