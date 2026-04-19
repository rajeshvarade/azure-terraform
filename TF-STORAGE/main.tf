resource "azurerm_resource_group" "stgac-batch20" {
  name     = "stgac-batch20"
  location = "Central India"
}

resource "azurerm_storage_account" "stgacbatch20storage" {
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

resource "azurerm_storage_container" "container-stgac-batch20" {
  name                  = "rajesh23conatainer"
  storage_account_name    = azurerm_storage_account.stgacbatch20storage.name
  container_access_type = "blob"

  depends_on = [azurerm_storage_account.stgacbatch20storage]

}

resource "azurerm_storage_blob" "blob-stgac" {
  name                   = "img1"
  storage_account_name   = azurerm_storage_account.stgacbatch20storage.name
  storage_container_name = azurerm_storage_container.container-stgac-batch20.name
  type                   = "Block"
  source                 = "img1.jpeg"

  content_type           = "image/jpeg"

  depends_on = [azurerm_storage_container.container-stgac-batch20]  
}
