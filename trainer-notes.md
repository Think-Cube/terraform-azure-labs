# Trainer Notes — Terraform on Microsoft Azure (2‑Day Hands‑On)

These notes help you run the training as **hands‑on**, not “slides only”. They tell you **what to live‑code**, **when to pause**, and **what to watch for**.

## Core delivery rules
- **Never read code from slides.** Live‑code the first instance of every concept, then move to labs.
- **Stop points:** after each live‑coding block, make everyone run the same commands.
- **Always show `terraform plan` before `apply`.** Ask: *create / update / replace?*
- Keep a clean story: init → plan → apply → verify → cleanup.

## Repo map
- `day1/infra` — foundations
- `day2/infra` — mini‑project root
- `day2/modules` — network/security/storage
- `labs/` — LAB1–LAB7
- `live-coding/` — LC1–LC6 scripts

---

# Day 1 — recommended flow

## LC1 — Bootstrap Day1 project (foundation)
**Files:** `day1/infra/*`
- versions/provider pinning
- variables + validations
- locals naming/tags
- RG + Storage

**Stop point:** everyone runs
```bash
cd day1/infra
terraform fmt -recursive
terraform validate
terraform init
terraform plan -var-file=env/staging.tfvars
```
Then: participants do **LAB1**.

## LC2 — Plan reading + safe changes
- show `+`, `~`, `-/+`
- do a safe change (tag)
- optionally demonstrate replacement risk

**Stop point:** participants repeat `plan/apply` with their own tag change.

## LC3 — Remote state + migration
Do backend bootstrap once, then LAB2.

**If possible:** lock contention demo (two terminals applying).

---

# Day 2 — recommended flow

## LC4 — Meta‑arguments + lifecycle (guided sandbox)
- `for_each` vs `count`
- `prevent_destroy`
- `ignore_changes`

**Stop point:** LAB3 + LAB4.

## LC5 — Dynamic NSG rules
- modify `nsg_rules` input
- plan/apply

**Stop point:** LAB5.

## LC6 — Modules: interface first
- show module contracts (inputs/outputs)
- wire modules in root
- DO NOT type whole modules live

**Stop point:** LAB6.

## Bonus (optional)
- drift detection + import demo → LAB7.

---

# Instructor checklist
Before:
- confirm correct subscription selected (`az account show`)
- ensure RBAC allows RG/VNET/NSG/Storage
- decide: backend per participant or shared

During:
- watch for naming constraints failures
- enforce plan review before apply

After:
- remind cleanup to avoid costs
