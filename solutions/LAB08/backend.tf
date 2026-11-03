# Remote state in Azure Storage. Values come from backend.hcl (partial configuration),
# so the same code works for every participant and every environment:
#   terraform init -backend-config=backend.hcl
terraform {
  backend "azurerm" {
    use_azuread_auth = true # Entra ID instead of storage account keys
  }
}
