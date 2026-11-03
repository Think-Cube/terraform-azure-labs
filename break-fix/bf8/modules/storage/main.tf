variable "name" {
  type        = string
  description = "Storage account name (3-24 lowercase letters and digits)"
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

resource "azurerm_storage_account" "this" {
  name                     = var.name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

output "id" {
  value = azurerm_storage_account.this.id
}
