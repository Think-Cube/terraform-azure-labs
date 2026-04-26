# LAB 5 — Dynamic NSG Rules (modifications)

**Goal:** Practice dynamic blocks driven by `map(object)` inputs.

## Tasks
1) Add `allow-metrics` rule (port 9100 from `10.10.2.0/24`) to `nsg_rules`.
2) Change `allow-api` port from 8080 → 8443.
3) Plan & apply:
```bash
cd day2/infra
terraform plan -var-file=env/dev.tfvars
terraform apply -var-file=env/dev.tfvars
```
4) Verify in portal.

## Done when
- rules appear in Azure NSG
- plan shows clean updates
