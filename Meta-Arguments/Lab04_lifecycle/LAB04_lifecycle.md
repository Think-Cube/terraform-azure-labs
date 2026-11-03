# LAB 4 — lifecycle

**Goal:** Control how Terraform replaces and protects resources using `lifecycle` blocks.

## Three arguments covered

| argument | what it does |
|---|---|
| `prevent_destroy` | plan errors if Terraform would destroy this resource |
| `ignore_changes` | drift in listed attributes is silently ignored |
| `create_before_destroy` | new resource is created before the old one is deleted |

## Start
```bash
cd Lab04_lifecycle/infra
```
Set a unique `project` value in `env/dev.tfvars`.
```bash
terraform init
terraform plan  -var-file=env/dev.tfvars
terraform apply -var-file=env/dev.tfvars
```

## Tasks

### 1 — prevent_destroy
Try to destroy:
```bash
terraform destroy -var-file=env/dev.tfvars
```
Observe the error. `prevent_destroy` blocks the plan.

### 2 — ignore_changes
Go to the Azure portal → Storage Account → add or change a tag.
```bash
terraform plan -var-file=env/dev.tfvars
```
Plan shows **no changes** — the tag drift is ignored.

### 3 — create_before_destroy
Change `vnet_address_space` to `"10.1.0.0/16"` in `dev.tfvars`:
```bash
terraform plan -var-file=env/dev.tfvars
```
Find the line `# (because create_before_destroy is true)` in the plan output.
This tells you the replacement order: create new → destroy old.

### 4 — Cleanup
1. In `main.tf`, **comment out** the `lifecycle { prevent_destroy = true }` block on the RG.
2. Run:
```bash
terraform destroy -var-file=env/dev.tfvars
```

## Done when
- `destroy` was blocked by `prevent_destroy`
- tag drift was invisible to plan
- plan showed `create_before_destroy` for the VNet replacement
- `destroy` succeeded after removing `prevent_destroy`
