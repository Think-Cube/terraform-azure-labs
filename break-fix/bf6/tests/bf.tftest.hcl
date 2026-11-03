mock_provider "azurerm" {
  source = "../mocks/azurerm"
}

mock_provider "random" {}

variables {
  prefix             = "bf"
  sql_admin_password = "Not-A-Real-Password-1"
}

run "configuration_works" {
  command = apply
}
