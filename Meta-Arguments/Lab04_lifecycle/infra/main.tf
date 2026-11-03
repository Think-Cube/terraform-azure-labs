resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-${local.name_prefix}"
  location = var.location
  tags     = local.common_tags

  # prevent_destroy: terraform destroy will error instead of deleting this resource.
  # Remove this block before running destroy at the end of the lab.
  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_storage_account" "sa" {
  name                     = local.storage_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = local.common_tags

  # ignore_changes: drift in these attributes will not appear in terraform plan.
  # Try changing the tags manually in the portal — plan will stay clean.
  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${local.name_prefix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = [var.vnet_address_space]
  tags                = local.common_tags

  # create_before_destroy: when a replacement is needed, create the new resource
  # first, then destroy the old one (default is destroy-first).
  lifecycle {
    create_before_destroy = true
  }
}
