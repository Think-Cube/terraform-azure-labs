# Mock values for azurerm in `terraform test` - IDs must look like real ARM IDs,
# because the provider validates them even when the API is mocked.

mock_data "azurerm_client_config" {
  defaults = {
    client_id       = "11111111-1111-1111-1111-111111111111"
    object_id       = "22222222-2222-2222-2222-222222222222"
    subscription_id = "00000000-0000-0000-0000-000000000000"
    tenant_id       = "33333333-3333-3333-3333-333333333333"
  }
}

mock_resource "azurerm_resource_group" {
  defaults = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-mock"
  }
}

mock_resource "azurerm_storage_account" {
  defaults = {
    id                    = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-mock/providers/Microsoft.Storage/storageAccounts/stmock"
    primary_blob_endpoint = "https://stmock.blob.core.windows.net/"
  }
}

mock_resource "azurerm_storage_container" {
  defaults = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-mock/providers/Microsoft.Storage/storageAccounts/stmock/blobServices/default/containers/mock"
  }
}

mock_resource "azurerm_virtual_network" {
  defaults = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-mock/providers/Microsoft.Network/virtualNetworks/vnet-mock"
  }
}

mock_resource "azurerm_subnet" {
  defaults = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-mock/providers/Microsoft.Network/virtualNetworks/vnet-mock/subnets/snet-mock"
  }
}

mock_resource "azurerm_network_security_group" {
  defaults = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-mock/providers/Microsoft.Network/networkSecurityGroups/nsg-mock"
  }
}

mock_resource "azurerm_key_vault" {
  defaults = {
    id        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-mock/providers/Microsoft.KeyVault/vaults/kv-mock"
    vault_uri = "https://kv-mock.vault.azure.net/"
  }
}

mock_resource "azurerm_user_assigned_identity" {
  defaults = {
    id           = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-mock/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-mock"
    principal_id = "44444444-4444-4444-4444-444444444444"
    client_id    = "55555555-5555-5555-5555-555555555555"
    tenant_id    = "33333333-3333-3333-3333-333333333333"
  }
}
