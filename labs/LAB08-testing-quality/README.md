# LAB 08 – Testing and code quality

> **Story:** After last week's outage (a storage account named with an underscore broke the pipeline at 2 a.m.), GreenGrid wants mistakes caught on the laptop and in pull requests – in seconds, without touching Azure.

| | |
|---|---|
| **Duration** | ~45 min |
| **You create** | `tests/greengrid.tftest.hcl`, `tests/mocks/azurerm/`, `checks.tf`, `.tflint.hcl` |
| **Solution** | `solutions/LAB08/` (or `./bin/catchup 8`) |

| Layer | Tool | Catches |
|---|---|---|
| formatting | `terraform fmt -check` | style |
| syntax & types | `terraform validate` | typos, wrong types, missing arguments |
| linting | **tflint** + azurerm ruleset | invalid SKUs/sizes, deprecated syntax, unused declarations |
| unit tests | `terraform test` + mock providers | naming, tagging, logic, validations – no Azure |
| integration tests | `terraform test` with real providers | the real thing (slow, costs money) |
| runtime checks | `check` blocks | assertions after every plan/apply |
| policy | Azure Policy, Terraform Policy, OPA/Conftest, Checkov | security and compliance |

## Step 1 – Mock data

`terraform test` can replace a provider with a mock. The azurerm provider still validates IDs, so the mocks need realistic ones. Copy the prepared file:

```bash
mkdir -p tests/mocks/azurerm
cp ../../solutions/LAB08/tests/mocks/azurerm/azurerm.tfmock.hcl tests/mocks/azurerm/
grep -A3 'mock_resource "azurerm_storage_account"' tests/mocks/azurerm/azurerm.tfmock.hcl
```

## Step 2 – Unit tests

`tests/greengrid.tftest.hcl`:

```hcl
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
```

```bash
terraform test
```

✅ **Checkpoint:** `Success! 4 passed, 0 failed.` – in seconds, offline.

`command = plan` tests logic before anything exists; `command = apply` with mocks also gives you computed values (IDs, endpoints). `expect_failures` turns "this must be rejected" into a test.

**Break it on purpose:** change the storage name in `locals.tf` to `"st-${var.prefix}..."` and run the tests again – then revert.

## Step 3 – A check block

`checks.tf`:

```hcl
# Checks run after every plan and apply - they warn, they do not block.
check "storage_uses_https" {
  assert {
    condition     = startswith(module.storage.primary_blob_endpoint, "https://")
    error_message = "The blob endpoint must use HTTPS."
  }
}
```

| | Blocks the run? | Typical use |
|---|---|---|
| variable `validation` | yes | wrong input |
| `precondition` / `postcondition` | yes | assumptions about a resource |
| `check` | no – warning | health of the whole system (can use its own data source, e.g. an HTTP probe) |

## Step 4 – tflint

`.tflint.hcl`:

```hcl
plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

plugin "azurerm" {
  enabled = true
  version = "0.33.0"
  source  = "github.com/terraform-linters/tflint-ruleset-azurerm"
}
```

```bash
tflint --init
tflint --recursive
```

Introduce mistakes and lint again: a VM size `Standard_D2s_v99`, an unused variable, a module without a pinned version.

> tflint knows Azure: invalid SKUs, sizes and regions are found without an API call – `terraform validate` cannot do that.

## Step 5 – One command for the pipeline

```bash
terraform fmt -check -recursive && terraform validate && tflint --recursive && terraform test
```

This exact line runs in every pull request in LAB11.

## Bonus

- `terraform test -filter=tests/greengrid.tftest.hcl -verbose` – see the planned values per run.
- Write a test for prod: `environment = "prod"` must give `ZRS` replication. (Hint: expose the replication type as an output, or test the storage module directly with a test in `modules/storage/tests/`.)
- Run a security scanner: `checkov -d .` or `trivy config .`.

## Troubleshooting

| Symptom | Likely cause |
|---|---|
| `parsing "...": the number of segments didn't match` | a mock ID is not a real ARM ID – add a `mock_resource` with a proper `id` |
| `Cannot import resources from mock providers` | an `import` block in the config – add `override_resource` for its target |
| test asks for Azure credentials | `mock_provider` missing for a provider (azurerm, random, azapi…) |
| `tflint`: `plugin not found` | run `tflint --init` once |
