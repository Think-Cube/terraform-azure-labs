variable "prefix" {
  type = string
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

resource "azurerm_subnet" "app" {
  name                 = "snet-app"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.30.1.0/24"]

  # "the NSG must be ready before the subnet" - says a colleague
  depends_on = [azurerm_subnet_network_security_group_association.app]
}

resource "azurerm_network_security_group" "app" {
  name                = "nsg-app-${var.prefix}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
}

resource "azurerm_subnet_network_security_group_association" "app" {
  subnet_id                 = azurerm_subnet.app.id
  network_security_group_id = azurerm_network_security_group.app.id
}
