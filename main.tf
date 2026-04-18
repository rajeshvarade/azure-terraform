resource "azurerm_resource_group" "rg" {
  name     = "batch-20"
  location = "Central India"

   tags = {
    environment = "Production"
  }
}