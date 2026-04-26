# LAB 6 — Mini Project (Modules End‑to‑End)

**Goal:** Build the mini environment using modules.

## Start
```bash
cd day2/infra
terraform fmt -recursive
terraform init
terraform validate
```

## Tasks
1) Plan to file:
```bash
terraform plan -var-file=env/dev.tfvars -out=tfplan
```
2) Apply:
```bash
terraform apply tfplan
```
3) Verify: RG, VNET, 2 subnets, NSG, Storage with default deny + subnet allow‑list.

4) Reinforcement:
- add third subnet `snet-mgmt` (10.10.3.0/24)
- add SSH rule only from `snet-mgmt` CIDR
- plan + apply

5) Cleanup:
```bash
terraform destroy -var-file=env/dev.tfvars
```

## Done when
- infra matches architecture
- updates apply cleanly
