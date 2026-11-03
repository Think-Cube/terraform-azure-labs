resource "azurerm_resource_group" "main" {
  name     = "rg-${local.name_suffix}"
  location = var.location
  tags     = local.common_tags
}

# Storage account names are global: add a random suffix
resource "random_string" "suffix" {
  length  = 4
  upper   = false
  special = false
}

resource "azurerm_storage_account" "data" {
  name                     = local.storage_name
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = var.environment == "prod" ? "ZRS" : "LRS"
  min_tls_version          = "TLS1_2"
  tags                     = local.common_tags

  blob_properties {
    versioning_enabled = true
  }

  network_rules {
    default_action             = local.is_prod ? "Deny" : "Allow"
    bypass                     = ["AzureServices"]
    ip_rules                   = var.allowed_ips
    virtual_network_subnet_ids = [azurerm_subnet.this["app"].id]
  }

  lifecycle {
    # the audit team stamps this tag by hand - do not fight them
    ignore_changes = [tags["last_audit"]]
  }
}

# for_each: one container per zone, addressed by name -> removing a zone touches only that zone
resource "azurerm_storage_container" "zone" {
  for_each           = var.data_zones
  name               = each.key
  storage_account_id = azurerm_storage_account.data.id
}

# The containers were created with count first - moved blocks keep them during the refactoring
moved {
  from = azurerm_storage_container.zone[0]
  to   = azurerm_storage_container.zone["raw"]
}

moved {
  from = azurerm_storage_container.zone[1]
  to   = azurerm_storage_container.zone["curated"]
}

moved {
  from = azurerm_storage_container.zone[2]
  to   = azurerm_storage_container.zone["reports"]
}

# count as an on/off switch
resource "azurerm_storage_container" "archive" {
  count              = var.enable_archive ? 1 : 0
  name               = "archive"
  storage_account_id = azurerm_storage_account.data.id
}

# You need a data-plane role to upload blobs with Entra ID
resource "azurerm_role_assignment" "me_blob_contributor" {
  scope                = azurerm_storage_account.data.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_storage_blob" "readme" {
  name                 = "README.txt"
  storage_container_id = azurerm_storage_container.zone["raw"].id
  type                 = "Block"
  source_content       = "GreenGrid raw meter readings land here.\n"

  # no reference to the role assignment - but the upload fails without it
  depends_on = [azurerm_role_assignment.me_blob_contributor]
}
