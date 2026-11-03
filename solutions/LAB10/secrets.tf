resource "azurerm_key_vault" "main" {
  name                       = "kv-${var.prefix}-gg-${random_string.suffix.result}"
  resource_group_name        = azurerm_resource_group.main.name
  location                   = azurerm_resource_group.main.location
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  rbac_authorization_enabled = true # Azure RBAC instead of access policies
  purge_protection_enabled   = false
  soft_delete_retention_days = 7
  tags                       = local.common_tags
}

resource "azurerm_role_assignment" "me_kv_secrets_officer" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

# Ephemeral: generated during plan/apply, never written to the plan file or the state
ephemeral "random_password" "db_admin" {
  length  = 24
  special = true
}

resource "azurerm_key_vault_secret" "db_admin_password" {
  name         = "db-admin-password"
  key_vault_id = azurerm_key_vault.main.id

  # write-only: sent to Azure, not stored in the state; bump the version to rotate
  value_wo         = ephemeral.random_password.db_admin.result
  value_wo_version = 1

  depends_on = [azurerm_role_assignment.me_kv_secrets_officer]
}

# Identity for the GreenGrid ingestion service - no passwords at all
resource "azurerm_user_assigned_identity" "ingest" {
  name                = "id-ingest-${local.name_suffix}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  tags                = local.common_tags
}

resource "azurerm_role_assignment" "ingest_blob_reader" {
  scope                = module.storage.id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azurerm_user_assigned_identity.ingest.principal_id
  principal_type       = "ServicePrincipal"
}

resource "azurerm_role_assignment" "ingest_secrets_user" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.ingest.principal_id
  principal_type       = "ServicePrincipal"
}
