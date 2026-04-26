# LC5 — Dynamic NSG Rules

**Outcome:** participants see `dynamic` blocks driven by input maps.

## Steps
1) Modify `day2/infra/env/dev.tfvars` live:
- add `allow-metrics` (port 9100)
- change `allow-api` port to 8443

2) Plan/apply:
```bash
cd day2/infra
terraform plan -var-file=env/dev.tfvars
terraform apply -var-file=env/dev.tfvars
```

## Teaching points
- nested blocks from data
- stable keys = clean updates
