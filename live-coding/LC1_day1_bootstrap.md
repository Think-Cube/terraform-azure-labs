# LC1 — Day 1 Bootstrap (From Zero to First Apply)

**Outcome:** participants see the complete Terraform workflow end‑to‑end (RG + Storage).

## What you type
### Prep
```bash
cd day1/infra
terraform -version
az version
az login
az account list -o table
az account show -o json
```

### Workflow
```bash
terraform fmt -recursive
terraform validate
terraform init
terraform plan -var-file=env/staging.tfvars
terraform apply -var-file=env/staging.tfvars
terraform output
```

### Verify (talk track)
- RG exists
- Storage has HTTPS only, TLS1_2, versioning
- Tags present

### Cleanup (optional)
```bash
terraform destroy -var-file=env/staging.tfvars
```

## Teaching points
- plan before apply
- locals enforce standards
- storage naming constraints are real
