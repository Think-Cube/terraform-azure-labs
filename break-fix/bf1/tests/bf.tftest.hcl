mock_provider "azurerm" {
  source = "../mocks/azurerm"
}

mock_provider "random" {}

variables {
  prefix = "bf"
}

run "configuration_works" {
  command = apply
}
