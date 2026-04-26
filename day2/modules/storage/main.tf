locals {
  storage_name = substr(
    replace(lower("st${var.name_prefix}001"), "-", ""),
    0,
    24
  )
}

resource "azurerm_storage_account" "sa" {
  name                     = local.storage_name
  resource_group_name      = var.rg_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  https_traffic_only_enabled      = true
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false

  blob_properties { versioning_enabled = true }
  tags = var.tags
}

resource "azurerm_storage_account_network_rules" "rules" {
  storage_account_id         = azurerm_storage_account.sa.id
  default_action             = "Deny"
  bypass                     = ["AzureServices"]
  virtual_network_subnet_ids = var.subnet_ids
}
