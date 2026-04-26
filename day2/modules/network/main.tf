resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.name_prefix}"
  location            = var.location
  resource_group_name = var.rg_name
  address_space       = var.address_space
  tags                = var.tags
}

locals {
  subnet_map = { for s in var.subnets : s.name => s.cidr }
}

resource "azurerm_subnet" "subnet" {
  for_each             = local.subnet_map
  name                 = each.key
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [each.value]
  service_endpoints    = ["Microsoft.Storage"]
}
