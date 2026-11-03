# The subscription comes from ARM_SUBSCRIPTION_ID (see LAB01) - required since azurerm 4.0.
# Authentication: your `az login` session locally, OIDC in pipelines (LAB11).
provider "azurerm" {
  features {}
}
