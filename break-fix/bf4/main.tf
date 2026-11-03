variable "prefix" {
  type = string
}

variable "subnets" {
  type = list(object({
    name = string
    cidr = string
  }))
  default = [
    { name = "app", cidr = "10.30.1.0/24" },
    { name = "data", cidr = "10.30.2.0/24" },
  ]
}

resource "azurerm_resource_group" "main" {
  name     = "rg-${var.prefix}-breakfix"
  location = "westeurope"
}

resource "azurerm_virtual_network" "main" {
  name                = "vnet-${var.prefix}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  address_space       = ["10.30.0.0/16"]
}

resource "azurerm_subnet" "this" {
  for_each             = var.subnets
  name                 = "snet-${each.value.name}"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [each.value.cidr]
}
