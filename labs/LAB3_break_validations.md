# LAB 3 — Break Validations (and fix them)

**Goal:** Understand variable validations and error diagnosis.

## Start
```bash
cd day2/infra
terraform init
```

## Tasks
1) In `env/dev.tfvars` set invalid values:
- `environment = "production"`
- in `subnets`: `name = "a"`, `cidr = "10.10.1.0/99"`

2) Run plan and observe errors:
```bash
terraform plan -var-file=env/dev.tfvars
```

3) Fix the values and confirm plan succeeds.

## Done when
- you can explain validation errors
- plan succeeds after fixing inputs
