variable "prefix" {
  type = string
}

resource "azurerm_resource_group" "main" {
  name     = "rg-${var.prefix}-breakfix"
  location = "westeurope"
}

module "archive" {
  source = "./modules/storage"

  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
}

output "archive_id" {
  value = module.archive.id
}
