# LAB 02 – Variables, validations, locals and outputs

> **Story:** GreenGrid needs a *dev* and a *prod* environment from the same code – with the company naming and tagging standard enforced, and wrong input rejected before anything reaches Azure.

| | |
|---|---|
| **Duration** | ~40 min |
| **You edit** | `variables.tf`, new `locals.tf`, `main.tf`, `outputs.tf`, new `env/*.tfvars` |
| **Solution** | `solutions/LAB02/` (or `./bin/catchup 2`) |

| Block | Purpose |
|---|---|
| `variable` | input – differs per environment or user |
| `locals` | derived values and standards – computed once, used everywhere |
| `output` | results for people, pipelines and other configurations |
| `*.tfvars` | the values for one environment |

## Step 1 – Variables with validation

Replace `variables.tf`:

```hcl
variable "prefix" {
  type        = string
  description = "Your personal prefix (2-8 lowercase letters/digits) - unique in the shared subscription"

  validation {
    condition     = can(regex("^[a-z0-9]{2,8}$", var.prefix))
    error_message = "prefix must be 2-8 lowercase letters or digits."
  }
}

variable "environment" {
  type        = string
  description = "Environment name"

  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "environment must be dev, test or prod."
  }
}

variable "location" {
  type        = string
  description = "Azure region"
  default     = "westeurope"

  validation {
    condition     = contains(["westeurope", "northeurope", "swedencentral", "polandcentral"], var.location)
    error_message = "Use an EU region approved by GreenGrid: westeurope, northeurope, swedencentral or polandcentral."
  }
}

variable "owner" {
  type        = string
  description = "Team or person responsible for the resources"
  default     = "platform-team"
}

variable "extra_tags" {
  type        = map(string)
  description = "Additional tags merged into the standard tags"
  default     = {}
}
```

## Step 2 – Locals: naming and tagging standard

`locals.tf`:

```hcl
locals {
  name_suffix = "${var.prefix}-greengrid-${var.environment}"

  # Storage account: 3-24 characters, lowercase letters and digits only
  storage_name = substr(lower(replace("st${var.prefix}gg${var.environment}${random_string.suffix.result}", "-", "")), 0, 24)

  common_tags = merge(
    {
      project     = "greengrid"
      environment = var.environment
      owner       = var.owner
      managed_by  = "terraform"
    },
    var.extra_tags,
  )
}
```

Use them in `main.tf`:

| Resource | Change |
|---|---|
| resource group | `name = "rg-${local.name_suffix}"`, `tags = local.common_tags` |
| storage account | `name = local.storage_name`, `tags = local.common_tags` |
| storage account | `account_replication_type = var.environment == "prod" ? "ZRS" : "LRS"` |
| storage account | add `blob_properties { versioning_enabled = true }` |

## Step 3 – One file per environment

```bash
mkdir -p env
cat > env/dev.tfvars <<'EOF'
prefix      = "jk" # <- your own prefix
environment = "dev"
location    = "westeurope"
EOF
cat > env/prod.tfvars <<'EOF'
prefix      = "jk" # <- your own prefix
environment = "prod"
location    = "westeurope"
owner       = "operations"
EOF
rm terraform.tfvars
```

Add outputs (`outputs.tf`) for `storage_blob_endpoint` (`azurerm_storage_account.data.primary_blob_endpoint`) and `tags` (`local.common_tags`), each with a `description`.

```bash
terraform plan -var-file=env/dev.tfvars
```

✅ **Checkpoint:** the plan **replaces** the resource group and the storage account – their names changed (`-greengrid` → `-greengrid-dev`). Fine in a lab, a disaster in production (LAB04 shows `moved` blocks for renames that are only addresses). Apply.

## Step 4 – Break the validations

Try each one and read the error:

```bash
terraform plan -var-file=env/dev.tfvars -var="environment=production"
terraform plan -var-file=env/dev.tfvars -var="prefix=Jan_K"
terraform plan -var-file=env/dev.tfvars -var="location=eastus"
```

✅ **Checkpoint:** three clear error messages – and not a single API call to Azure.

Variable precedence (highest wins): `-var` / `-var-file` on the command line → `*.auto.tfvars` → `terraform.tfvars` → `TF_VAR_name` environment variables → `default`.

## Step 5 – terraform console

```bash
terraform console -var-file=env/dev.tfvars
```

```hcl
local.name_suffix
local.common_tags
lower("GreenGrid Meter-42")
replace("tf_train", "_", "-")
substr("abcdefghijklmnopqrstuvwxyz0123", 0, 24)
merge({ a = "1" }, { b = "2", a = "3" })
cidrsubnet("10.20.0.0/16", 8, 1)
```

Leave with `exit`.

## Bonus

- `sensitive = true` on a variable – what changes in the plan output?
- Add an `extra_tags = { costcenter = "4711" }` line to `env/prod.tfvars` and plan prod. (Do not apply prod – it would be a second copy of everything.)
- `terraform plan -var-file=env/dev.tfvars -out=dev.tfplan` and `terraform show dev.tfplan` – a plan file applies exactly what you reviewed.

## Troubleshooting

| Symptom | Likely cause |
|---|---|
| `No value for required variable "environment"` | forgot `-var-file=env/dev.tfvars` |
| `Reference to undeclared local value` | `locals.tf` not saved, or a typo in `local.<name>` |
| validation passes although the value is wrong | `condition` uses another variable – only `var.<self>` is allowed in older Terraform; since 1.9 other variables work too |
