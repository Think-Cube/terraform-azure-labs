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

# count creates N copies of this resource block.
# count.index is the current copy number, starting at 0.
resource "azurerm_virtual_network" "vnet" {
  count = var.vnet_count

  name                = "vnet-${local.name_prefix}-${count.index + 1}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.${count.index}.0.0/16"]
  tags                = local.common_tags
}
