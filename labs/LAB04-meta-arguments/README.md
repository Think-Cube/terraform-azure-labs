# LAB 04 – Meta-arguments: count, for_each, depends_on, lifecycle and moved

> **Story:** GreenGrid's data lake gets zones – *raw*, *curated*, *reports* – each a blob container. A first version with `count` works… until somebody removes a zone. You refactor it to `for_each` **without** deleting a single container.

| | |
|---|---|
| **Duration** | ~45 min |
| **You edit** | `providers.tf`, `variables.tf`, `main.tf`, `outputs.tf` |
| **Solution** | `solutions/LAB04/` (or `./bin/catchup 4`) |

| Meta-argument | Use it for |
|---|---|
| `count` | N identical copies – or an on/off switch (`count = var.enabled ? 1 : 0`) |
| `for_each` | one instance per key of a map or set – stable addresses |
| `depends_on` | dependencies Terraform cannot see in references |
| `lifecycle` | `prevent_destroy`, `create_before_destroy`, `ignore_changes`, `replace_triggered_by`, pre/postconditions |
| `provider` | an alternative provider configuration (another subscription/region) |

## Step 1 – Containers with count

In `providers.tf` let data-plane calls use Entra ID and read who you are:

```hcl
provider "azurerm" {
  features {}
  storage_use_azuread = true # data-plane calls (blobs) with Entra ID, not account keys
}

data "azurerm_client_config" "current" {}
```

`main.tf` – the first, naive version:

```hcl
variable "zone_list" {
  type    = list(string)
  default = ["raw", "curated", "reports"]
}

resource "azurerm_storage_container" "zone" {
  count              = length(var.zone_list)
  name               = var.zone_list[count.index]
  storage_account_id = azurerm_storage_account.data.id
}
```

```bash
terraform apply -var-file=env/dev.tfvars
terraform state list | grep container
```

Addresses: `zone[0]`, `zone[1]`, `zone[2]`.

## Step 2 – The count trap

The data team drops the *curated* zone. Change the default to `["raw", "reports"]` and plan:

```bash
terraform plan -var-file=env/dev.tfvars
```

✅ **Checkpoint:** Terraform wants to **replace `zone[1]`** (curated → reports) **and destroy `zone[2]`** – the *reports* data would be deleted although you never touched it. Indexes shifted. **Do not apply** – restore the three zones.

## Step 3 – for_each with stable keys, refactored with moved

Replace the variable and the resource:

```hcl
variable "data_zones" {
  type        = set(string)
  description = "Data lake zones - one blob container each"
  default     = ["raw", "curated", "reports"]
}

resource "azurerm_storage_container" "zone" {
  for_each           = var.data_zones
  name               = each.key
  storage_account_id = azurerm_storage_account.data.id
}
```

Plan now: Terraform would destroy `zone[0..2]` and create `zone["raw"]`… – same containers, new addresses. Tell it they **moved**:

```hcl
moved {
  from = azurerm_storage_container.zone[0]
  to   = azurerm_storage_container.zone["raw"]
}

moved {
  from = azurerm_storage_container.zone[1]
  to   = azurerm_storage_container.zone["curated"]
}

moved {
  from = azurerm_storage_container.zone[2]
  to   = azurerm_storage_container.zone["reports"]
}
```

✅ **Checkpoint:** `Plan: 0 to add, 0 to change, 0 to destroy` with three lines *has moved to*. Apply. Removing a zone from the set would now touch only that zone.

> `moved` blocks are reviewed in Git and work for everybody using the state – unlike `terraform state mv` on one laptop. Delete them once every environment has applied them.

## Step 4 – count as a switch

```hcl
variable "enable_archive" {
  type        = bool
  description = "Create the archive container"
  default     = false
}

resource "azurerm_storage_container" "archive" {
  count              = var.enable_archive ? 1 : 0
  name               = "archive"
  storage_account_id = azurerm_storage_account.data.id
}
```

Plan with `-var="enable_archive=true"` and without. Reference it safely elsewhere with `one(azurerm_storage_container.archive[*].id)`.

## Step 5 – depends_on: a hidden dependency

Uploading a blob with Entra ID needs a data-plane role. Nothing in the blob refers to the role – Terraform would happily do both at the same time:

```hcl
resource "azurerm_role_assignment" "me_blob_contributor" {
  scope                = azurerm_storage_account.data.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_storage_blob" "readme" {
  name                 = "README.txt"
  storage_container_id = azurerm_storage_container.zone["raw"].id
  type                 = "Block"
  source_content       = "GreenGrid raw meter readings land here.\n"

  # no reference to the role assignment - but the upload fails without it
  depends_on = [azurerm_role_assignment.me_blob_contributor]
}
```

✅ **Checkpoint:** the apply creates the role assignment **before** the blob (watch the order). If it still fails with 403, wait a minute and apply again – RBAC propagation is eventually consistent.

## Step 6 – lifecycle

Add to the storage account:

```hcl
  lifecycle {
    # the audit team stamps this tag by hand - do not fight them
    ignore_changes = [tags["last_audit"]]
  }
```

Then experiment (and revert afterwards):

1. `az storage account update -g rg-<prefix>-greengrid-dev -n <storage> --tags last_audit=2026-11-03 project=greengrid environment=dev owner=platform-team managed_by=terraform` → plan: **no changes**.
2. Add `prevent_destroy = true` to the lifecycle block and run `terraform plan -destroy -var-file=env/dev.tfvars` → *Instance cannot be destroyed*.
3. On `random_string.suffix` try `replace_triggered_by` – which resources would be re-created?

Add an output with all container names:

```hcl
output "container_names" {
  description = "Blob containers per data zone"
  value       = { for zone, c in azurerm_storage_container.zone : zone => c.name }
}
```

## Troubleshooting

| Symptom | Likely cause |
|---|---|
| `The "for_each" set includes values derived from resource attributes` | for_each keys must be known at plan time – use input values, not resource IDs |
| `Moved object still exists` | the old `count` resource block is still in the code |
| blob upload `403 AuthorizationPermissionMismatch` | role not propagated yet – re-apply after a minute |
| `prevent_destroy` blocks the end-of-course cleanup | remove it first – it is a guard for production |
