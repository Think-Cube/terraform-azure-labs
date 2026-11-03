# LAB 2 — for_each

**Goal:** Create resources from a map and a set using `for_each`.

## Key concept
```hcl
# map — each.key and each.value are different
resource "azurerm_virtual_network" "vnet" {
  for_each      = var.vnets           # map(object)
  name          = "vnet-${each.key}"  # "vnet-shared", "vnet-dev", "vnet-prod"
  address_space = [each.value.address_space]
}

# set — each.key == each.value (the string itself)
resource "azurerm_resource_group" "extra" {
  for_each = toset(["northeurope", "westeurope"])
  name     = "rg-extra-${each.value}"
  location = each.key
}

# reference one:  azurerm_virtual_network.vnet["prod"]
```

## Start
```bash
cd Lab02_for_each/infra
```
Set a unique `project` value in `env/dev.tfvars`.
```bash
terraform init
terraform plan  -var-file=env/dev.tfvars
terraform apply -var-file=env/dev.tfvars
terraform output
```

## Tasks
1) Add a new VNet entry `staging` (address `10.3.0.0/16`) to `vnets` in `dev.tfvars`.
   Plan and apply — how many resources change?

2) Remove the `dev` VNet from the map.
   Plan — which resources are affected? Does removing one key change the others?

3) Add `"northeurope"` to `extra_locations`. Plan — what's the Terraform resource address?

> **vs count:** removing `dev` from the map destroys only that VNet.
> With `count`, removing a middle element renumbers the list and can destroy the wrong resource.

## Cleanup
```bash
terraform destroy -var-file=env/dev.tfvars
```

## Done when
- initial apply created 3 VNets + 1 extra RG
- you confirmed that removing one map key only affected that resource
