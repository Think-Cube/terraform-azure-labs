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

# ── Part A: azapi_resource ────────────────────────────────────────────────────
# Creates a VNet by calling the Azure REST API directly.
# Compare with azurerm_virtual_network — same result, but you write raw JSON
# that maps 1-to-1 with the ARM API schema.
#
# type      = "<ARM resource type>@<API version>"
# parent_id = the resource group (parent in the ARM hierarchy)
# body      = JSON matching https://learn.microsoft.com/en-us/rest/api/virtualnetwork/
resource "azapi_resource" "vnet" {
  type      = "Microsoft.Network/virtualNetworks@2023-04-01"
  name      = "vnet-${local.name_prefix}"
  parent_id = azurerm_resource_group.rg.id
  location  = var.location
  tags      = local.common_tags

  body = jsonencode({
    properties = {
      addressSpace = {
        addressPrefixes = ["10.0.0.0/16"]
      }
    }
  })
}

# ── Part B: azapi_update_resource ─────────────────────────────────────────────
# Create a Storage Account the normal azurerm way.
resource "azurerm_storage_account" "sa" {
  name                     = local.storage_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = local.common_tags
}

# Patch the Storage Account with a property azurerm 3.x does not expose:
# allowedCopyScope = "AAD" restricts object copy operations to requests
# authenticated with Entra ID only (rejects shared-key copy).
# azapi_update_resource merges the body into the existing resource —
# it does NOT replace the whole resource.
resource "azapi_update_resource" "sa_copy_scope" {
  type        = "Microsoft.Storage/storageAccounts@2023-01-01"
  resource_id = azurerm_storage_account.sa.id

  body = jsonencode({
    properties = {
      allowedCopyScope = "AAD"
    }
  })
}
