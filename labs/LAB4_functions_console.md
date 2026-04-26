# LAB 4 — Functions + terraform console

**Goal:** Practice naming/tagging functions.

## Tasks
1) Run console:
```bash
cd day2/infra
terraform console
```

2) Evaluate:
```hcl
lower("HELLO WORLD")
replace("tf_train", "_", "-")
substr("abcdefghijklmnop", 0, 10)
merge({a="1"},{b="2"})
```

3) Update storage naming in `day2/modules/storage/main.tf` so it also removes `_`.

4) Plan:
```bash
terraform fmt -recursive
terraform plan -var-file=env/dev.tfvars
```

## Done when
- naming change keeps constraints and plan succeeds
