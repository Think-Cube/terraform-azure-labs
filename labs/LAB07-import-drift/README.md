# LAB 07 – Import, drift and removed

> **Story:** GreenGrid still has a *legacy* resource group that someone created in the portal years ago, a colleague "quickly" changes tags in the portal, and the data team takes over the README blob. Time to bring reality and code back together.

| | |
|---|---|
| **Duration** | ~40 min |
| **You create** | `legacy.tf`; you edit `main.tf` |
| **Solution** | `solutions/LAB07/` (or `./bin/catchup 7`) |

| Situation | Tool |
|---|---|
| a resource exists in Azure, not in Terraform | `import` block (+ `-generate-config-out`) |
| many existing resources | `terraform query` (list resources) or **aztfexport** |
| someone changed Azure, not the code | drift: `terraform plan`, then decide |
| Terraform should forget a resource but not delete it | `removed` block |

## Step 1 – Something created by hand

```bash
P=jk   # <- your prefix
az group create -n rg-$P-legacy -l westeurope --tags owner=someone-who-left -o none
```

## Step 2 – import block with generated configuration

`legacy.tf`:

```hcl
import {
  to = azurerm_resource_group.legacy
  id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/rg-${var.prefix}-legacy"
}
```

Let Terraform write the resource block for you:

```bash
terraform plan -var-file=env/dev.tfvars -generate-config-out=generated.tf
cat generated.tf
```

✅ **Checkpoint:** `generated.tf` contains an `azurerm_resource_group "legacy"` block with the values read from Azure; the plan says `1 to import`.

Generated code is a starting point, not a result. Move the block into `legacy.tf`, delete `generated.tf`, and bring it to the GreenGrid standard:

```hcl
resource "azurerm_resource_group" "legacy" {
  name     = "rg-${var.prefix}-legacy"
  location = var.location
  tags     = merge(local.common_tags, { legacy = "true" })
}
```

```bash
terraform plan -var-file=env/dev.tfvars
terraform apply -var-file=env/dev.tfvars
```

✅ **Checkpoint:** the plan shows **import + update in place** (the tags change from `owner=someone-who-left` to the standard tags) – reviewed before it happens. After apply, `terraform state show azurerm_resource_group.legacy` works.

> The `import` block may stay in the code (it is a no-op once imported) – or be deleted after every environment applied it. The old `terraform import` command still works but changes the state immediately, without a plan.

## Step 3 – Drift

Play the colleague in the portal:

```bash
az group update -n rg-$P-greengrid-dev --set tags.environment=production -o none
az network nsg rule create -g rg-$P-greengrid-dev --nsg-name nsg-app-$P-greengrid-dev \
  -n allow-rdp --priority 200 --destination-port-ranges 3389 --access Allow -o none
terraform plan -var-file=env/dev.tfvars
```

✅ **Checkpoint:** Terraform reports the tag change and the unknown RDP rule and plans to **revert both**.

Decide per change: revert (apply), or adopt (change the code), or tolerate (`ignore_changes`). Here: apply – an RDP port open to the world is not a matter of taste.

> `terraform plan -refresh-only` shows drift without proposing changes; `terraform apply -refresh-only` writes the real values into the state only.

## Step 4 – removed: hand over a resource

The data team now manages the README blob. Delete the `azurerm_storage_blob.readme` resource from `main.tf` and add to `legacy.tf`:

```hcl
removed {
  from = azurerm_storage_blob.readme

  lifecycle {
    destroy = false
  }
}
```

```bash
terraform plan -var-file=env/dev.tfvars
```

✅ **Checkpoint:** `azurerm_storage_blob.readme will no longer be managed by Terraform` – **not** destroyed. Apply; the blob is still in Azure (`az storage blob list ... -c raw --auth-mode login`).

## Step 5 – Bulk import (demo)

For a whole resource group, write configuration with **aztfexport**:

```bash
aztfexport resource-group --non-interactive --output-dir /tmp/export rg-$P-legacy
ls /tmp/export
```

Or, since Terraform 1.14, query existing resources with list blocks in a `*.tfquery.hcl` file and `terraform query -generate-config-out=...` (for providers that support list resources).

## Troubleshooting

| Symptom | Likely cause |
|---|---|
| `Cannot import non-existent remote object` | the resource group name/ID in the import block does not match Azure |
| `Resource already managed by Terraform` | already imported – remove the import block or ignore |
| `-generate-config-out` refuses: file exists | delete `generated.tf` first |
| removed block plans a destroy | `destroy = false` missing in the `lifecycle` block |
