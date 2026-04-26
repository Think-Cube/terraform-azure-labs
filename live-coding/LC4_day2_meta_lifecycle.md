# LC4 — Meta‑arguments + lifecycle (guided)

**Outcome:** participants understand `for_each` and lifecycle safety.

## Steps
1) Create `day2/infra/meta-demo.tf`:
```hcl
variable "extra_rgs" {
  type    = set(string)
  default = ["ops", "shared"]
}

resource "azurerm_resource_group" "extra" {
  for_each = var.extra_rgs
  name     = "rg-${local.name_prefix}-${each.value}"
  location = var.location
  tags     = local.common_tags
}
```

2) Run plan/apply:
```bash
cd day2/infra
terraform init
terraform plan -var-file=env/dev.tfvars
terraform apply -var-file=env/dev.tfvars
```

3) Demonstrate `prevent_destroy` (optional): add lifecycle to one RG, try `destroy`.

## Teaching points
- `for_each` keeps stable addresses
- lifecycle can protect critical infra
