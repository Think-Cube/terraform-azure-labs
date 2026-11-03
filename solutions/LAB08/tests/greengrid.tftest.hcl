# Unit tests: no Azure needed - providers are mocked (tests/mocks/azurerm).
# Run: terraform init -backend=false && terraform test

mock_provider "azurerm" {
  source = "./tests/mocks/azurerm"
}

mock_provider "random" {}

# The import block (legacy.tf) cannot import from a mocked provider - give the resource fixed values instead
override_resource {
  target = azurerm_resource_group.legacy
  values = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-jk-legacy"
  }
}

# Deterministic names: pin the random suffix
override_resource {
  target = random_string.suffix
  values = {
    result = "a1b2"
  }
}

variables {
  prefix      = "jk"
  environment = "dev"
}

run "names_follow_the_standard" {
  command = apply

  assert {
    condition     = azurerm_resource_group.main.name == "rg-jk-greengrid-dev"
    error_message = "Resource group name does not follow rg-<prefix>-greengrid-<env>."
  }

  assert {
    condition     = output.storage_account_name == "stjkggdeva1b2"
    error_message = "Storage account name must be st<prefix>gg<env><4 random chars>."
  }
}

run "every_resource_is_tagged" {
  command = plan

  assert {
    condition     = alltrue([for k in ["project", "environment", "owner", "managed_by"] : contains(keys(output.tags), k)])
    error_message = "Standard tags are missing."
  }
}

run "prod_settings_follow_the_environment" {
  command = plan

  variables {
    environment = "prod"
  }

  assert {
    condition     = output.tags.environment == "prod"
    error_message = "Environment tag must follow the variable."
  }
}

run "rejects_an_invalid_prefix" {
  command = plan

  variables {
    prefix = "Bad_Prefix"
  }

  expect_failures = [var.prefix]
}

run "rejects_an_unknown_environment" {
  command = plan

  variables {
    environment = "production"
  }

  expect_failures = [var.environment]
}
