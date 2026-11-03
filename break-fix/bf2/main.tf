variable "prefix" {
  type = string
}

resource "azurerm_resource_group" "main" {
  name     = "rg-${var.prefix}-breakfix"
  location = "westeurope"
}

resource "random_string" "suffix" {
  length  = 4
  upper   = false
  special = false
}

locals {
  storage_name = "st-${var.prefix}-greengrid-reports-${random_string.suffix.result}"
}

resource "azurerm_storage_account" "reports" {
  name                     = local.storage_name
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

output "storage_name" {
  value = azurerm_storage_account.reports.name
}
