# LAB 1 — First Resources (Resource Group + Storage)

**Goal:** Deploy your first Azure resources and practice the core Terraform workflow.

## Start
```bash
cd day1/infra
terraform -version
az version
az login
az account show -o json
az account list -o table
```

## Tasks
### 1) Run the workflow
```bash
terraform fmt -recursive
terraform init
terraform validate
terraform plan -var-file=env/staging.tfvars
terraform apply -var-file=env/staging.tfvars
```

### 2) Verify in Azure Portal
- Resource Group name: `rg-<project>-<environment>`
- Storage Account settings: HTTPS only, min TLS 1.2, blob versioning enabled
- Tags exist on both resources

### 3) Your changes (reinforcement)
- In `env/staging.tfvars` set your own `project` (3–12 chars)
- Add 2 custom tags in `locals.tf` (`common_tags`)
- Run `plan` (review) then `apply`

### 4) Cleanup
```bash
terraform destroy -var-file=env/staging.tfvars
```

## Done when
- `apply` succeeded
- verified resources in portal
- `destroy` removed everything
