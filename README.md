# Terraform on Microsoft Azure — 2‑Day Hands‑On Training (Repo)

This repository is aligned with the course slides (**Terraform_na_Microsoft_Azure.pptx**). 

## Layout
- `day1/` — foundations + first resources + remote state
- `day2/` — advanced + modular mini‑project
- `labs/` — LAB 1–7 step‑by‑step instructions (participant handout)
- `live-coding/` — live coding scripts (what you type + checkpoints)
- `trainer-notes.md` — instructor notes to avoid “slides only” delivery

## Prerequisites
- Terraform: `terraform -version`
- Azure CLI: `az version`
- Login: `az login`

## Quick start
### Day 1
```bash
cd day1/infra
terraform fmt -recursive
terraform validate
terraform init
terraform plan -var-file=env/staging.tfvars
terraform apply -var-file=env/staging.tfvars
```

### Day 2
```bash
cd day2/infra
terraform fmt -recursive
terraform init
terraform validate
terraform plan -var-file=env/dev.tfvars -out=tfplan
terraform apply tfplan
```

> Remote state setup is in **LAB 2** (`labs/LAB2_remote_state.md`).
