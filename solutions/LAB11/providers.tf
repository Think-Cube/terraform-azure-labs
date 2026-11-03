# The subscription comes from ARM_SUBSCRIPTION_ID (see LAB01) - required since azurerm 4.0.
# Authentication: your `az login` session locally, OIDC in pipelines (LAB11).
provider "azurerm" {
  features {}
  storage_use_azuread = true # data-plane calls (blobs) with Entra ID, not account keys
}

data "azurerm_client_config" "current" {}

# Same credentials as azurerm (az login / OIDC) - no extra configuration
provider "azapi" {}
