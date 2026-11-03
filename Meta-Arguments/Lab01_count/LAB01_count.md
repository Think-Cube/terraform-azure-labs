# LAB 1 — count

**Goal:** Create multiple VNets with a single resource block using `count`.

## Key concept
```hcl
resource "azurerm_virtual_network" "vnet" {
  count = var.vnet_count                          # repeat N times
  name  = "vnet-${local.name_prefix}-${count.index + 1}"  # 0-based index
}

# reference one:  azurerm_virtual_network.vnet[0]
# reference all:  azurerm_virtual_network.vnet[*].name
```

## Start
```bash
cd Lab01_count/infra
```
Set a unique `project` value in `env/dev.tfvars` (your initials + a digit, e.g. `jk1`).
```bash
terraform init
terraform plan  -var-file=env/dev.tfvars
terraform apply -var-file=env/dev.tfvars
terraform output
```

## Tasks
1) Increase `vnet_count` to `5` → plan and apply. How many resources were added?
2) Decrease `vnet_count` to `2` → plan. Which VNets will be destroyed?
3) Apply the decrease. Check in the portal — which ones are gone?

> **Note:** `count` removes resources from the *end* of the list (highest index).
> Removing a middle element would renumber the remaining ones and destroy the wrong resource.
> That is the main limitation of `count` — use `for_each` when keys matter.

## Cleanup
```bash
terraform destroy -var-file=env/dev.tfvars
```

## Done when
- `apply` succeeded with 3 VNets
- you observed which VNets were destroyed when count dropped to 2
- `destroy` removed everything
