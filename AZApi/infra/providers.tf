provider "azurerm" {
  features {}
}

# azapi inherits authentication from azurerm (az login / env vars)
provider "azapi" {}

data "azurerm_client_config" "current" {}
