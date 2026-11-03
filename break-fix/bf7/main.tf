variable "prefix" {
  type = string
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "main" {
  name     = "rg-${var.prefix}-breakfix"
  location = "westeurope"
}

resource "azurerm_key_vault" "main" {
  name                       = "kv-${var.prefix}-breakfix"
  resource_group_name        = azurerm_resource_group.main.name
  location                   = azurerm_resource_group.main.location
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  rbac_authorization_enabled = true
}

ephemeral "random_password" "api_key" {
  length  = 32
  special = false
}

resource "azurerm_key_vault_secret" "api_key" {
  name         = "partner-api-key"
  key_vault_id = azurerm_key_vault.main.id
  value        = ephemeral.random_password.api_key.result
}
