# LAB 3 — depends_on

**Goal:** Understand when and why explicit dependencies are needed.

## Key concept

Terraform builds a dependency graph automatically **when one resource references another**:
```hcl
resource_group_name = azurerm_resource_group.rg.name  # implicit — Terraform waits
```

When there is **no reference** (e.g. a data source using a plain string), Terraform
does not know it must wait, and may fail. `depends_on` fixes that:
```hcl
data "azurerm_storage_account" "sa_info" {
  name = local.storage_name   # plain string — no implicit dependency!

  depends_on = [azurerm_storage_account.sa]   # explicit: wait for SA first
}
```

## Start
```bash
cd Lab03_depends_on/infra
```
Set a unique `project` value in `env/dev.tfvars`.
```bash
terraform init
terraform plan  -var-file=env/dev.tfvars
terraform apply -var-file=env/dev.tfvars
terraform output
```
Confirm `primary_blob_endpoint` is returned — the data source ran after the SA was ready.

## Tasks
1) In `main.tf`, comment out `depends_on` on the data source.
   Run `terraform plan` — does it show any issue?
   Run `terraform apply` on a **fresh state** (`terraform destroy` first) — does it fail?

2) Restore `depends_on` and apply again — confirm it works.

3) Look at `main.tf`: where does Terraform get an implicit dependency automatically?
   Where does it need help from `depends_on`?

## Cleanup
```bash
terraform destroy -var-file=env/dev.tfvars
```

## Done when
- apply succeeded with `depends_on` in place
- you reproduced (or understood) the failure without it
