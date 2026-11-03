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

# for_each with a map — each.key is the map key, each.value is the object
resource "azurerm_virtual_network" "vnet" {
  for_each = var.vnets

  name                = "vnet-${local.name_prefix}-${each.key}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = [each.value.address_space]
  tags                = merge(local.common_tags, { tier = each.value.tier })
}

# for_each with toset() — each.key == each.value (the string itself)
resource "azurerm_resource_group" "extra" {
  for_each = toset(var.extra_locations)

  name     = "rg-${local.name_prefix}-${each.value}"
  location = each.value
  tags     = local.common_tags
}
