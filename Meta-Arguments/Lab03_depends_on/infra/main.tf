resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-${local.name_prefix}"
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_storage_account" "sa" {
  name                     = local.storage_name
  resource_group_name      = azurerm_resource_group.rg.name  # implicit dependency
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = local.common_tags
}

# This data source reads the storage account by name from a local (a plain string).
# Terraform sees no resource reference here, so it does not know it must wait.
# Without depends_on it may try to read the SA before it exists — and fail.
data "azurerm_storage_account" "sa_info" {
  name                = local.storage_name         # plain string, not a resource ref
  resource_group_name = azurerm_resource_group.rg.name

  depends_on = [azurerm_storage_account.sa]
}
