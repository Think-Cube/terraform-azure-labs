resource "azurerm_resource_group" "main" {
  name     = "rg-${var.prefix}-greengrid"
  location = var.location
}

# Storage account names are global: add a random suffix
resource "random_string" "suffix" {
  length  = 4
  upper   = false
  special = false
}

resource "azurerm_storage_account" "data" {
  name                     = "st${var.prefix}gg${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
}
