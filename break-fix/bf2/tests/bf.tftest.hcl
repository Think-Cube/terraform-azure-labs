mock_provider "azurerm" {
  source = "../mocks/azurerm"
}

mock_provider "random" {}

variables {
  prefix = "bf"
}

run "configuration_works" {
  command = apply

  assert {
    condition     = can(regex("^[a-z0-9]{3,24}$", output.storage_name))
    error_message = "Storage account names are 3-24 lowercase letters and digits - got ${output.storage_name}."
  }
}
