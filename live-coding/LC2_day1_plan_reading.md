# LC2 — Reading `terraform plan` + Safe Changes

**Outcome:** participants learn to interpret create/update/replace.

## Steps
1) Ensure infra exists:
```bash
cd day1/infra
terraform init
terraform apply -var-file=env/staging.tfvars
```

2) Add a tag in `locals.tf` → `common_tags`:
```hcl
training = "day1"
```

3) Show plan and explain symbols:
```bash
terraform plan -var-file=env/staging.tfvars
```

4) Apply and verify:
```bash
terraform apply -var-file=env/staging.tfvars
```

5) Optional replacement demo (only if safe): change replication type and review whether it becomes `-/+`:
```hcl
account_replication_type = "GRS"
```
Then:
```bash
terraform plan -var-file=env/staging.tfvars
```

## Teaching points
- `+` create, `~` update, `-/+` replace
- replacements can be destructive
