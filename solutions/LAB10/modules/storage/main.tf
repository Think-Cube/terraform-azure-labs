resource "azurerm_storage_account" "this" {
  name                     = var.name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = var.replication_type
  min_tls_version          = "TLS1_2"
  tags                     = var.tags

  blob_properties {
    versioning_enabled = true
  }

  network_rules {
    default_action             = var.default_network_action
    bypass                     = ["AzureServices"]
    ip_rules                   = var.allowed_ips
    virtual_network_subnet_ids = var.allowed_subnet_ids
  }

  lifecycle {
    # the audit team stamps this tag by hand - do not fight them
    ignore_changes = [tags["last_audit"]]
  }
}

resource "azurerm_storage_container" "zone" {
  for_each           = var.zones
  name               = each.key
  storage_account_id = azurerm_storage_account.this.id
}

resource "azurerm_storage_container" "archive" {
  count              = var.enable_archive ? 1 : 0
  name               = "archive"
  storage_account_id = azurerm_storage_account.this.id
}
