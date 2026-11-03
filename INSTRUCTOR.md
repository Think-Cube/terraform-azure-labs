# Instructor guide

## Before the course

1. **Subscription:** one shared training subscription. Give every participant **Contributor** + **Role Based Access Control Administrator** (or Owner in a sandbox). Check that the resource providers `Microsoft.Storage`, `Microsoft.Network`, `Microsoft.KeyVault` and `Microsoft.ManagedIdentity` are registered – azurerm 5 no longer registers them automatically.
2. **Quota and policy:** Azure Policy that denies public storage or non-EU regions will (correctly) break some steps – test the labs in that subscription first.
3. **Workstations:** Terraform ≥ 1.14 (1.17.1 verified), Azure CLI, Git; tflint for LAB08. Azure Cloud Shell works for LAB01–LAB10 (check its Terraform version).
4. **LAB11:** tell participants a week ahead to bring a GitHub account or access to an Azure DevOps project where they can create a service connection.
5. Run the offline checks of the repository: every `solutions/LABnn` passes `terraform fmt -check`, `validate` and `terraform test` with mocked providers; `bash solutions/LAB12/fix.sh && ./bin/check-breakfix.sh` gives 8 / 8 (reset with `git checkout -- break-fix`).

## Suggested schedule (2 days, 9:00–16:00)

| | Day 1 – Foundations | Day 2 – Production-ready |
|---|---|---|
| 09:00 | IaC, Terraform architecture, workflow | Recap + quiz |
| 09:45 | **LAB01** first deployment | Import & drift → **LAB07** |
| 10:45 | ☕ | ☕ |
| 11:00 | Variables, locals, outputs → **LAB02** | Testing & quality → **LAB08** |
| 12:00 | Authentication & state → **LAB03** | 🍽 |
| 12:45 | 🍽 | AzAPI → **LAB09** |
| 13:30 | Meta-arguments → **LAB04** | Secrets & identity → **LAB10** |
| 14:30 | Expressions & dynamic blocks → **LAB05** | CI/CD → **LAB11** |
| 15:15 | Modules → **LAB06** (finish as homework if needed) | **LAB12** break-fix, wrap-up |

Anyone who falls behind: `./bin/catchup <N>`.

## Teaching notes

- **Versions matter:** azurerm 4.0 made `subscription_id` mandatory (`ARM_SUBSCRIPTION_ID`), azurerm 5.0 stopped registering resource providers and turned `service_endpoints` into a `service_endpoint` block; AzAPI 2.0 takes the body as an HCL object. Most blog posts still show the old syntax – BF1 is built on that.
- **LAB01** – insist on reading the plan symbols aloud; the location change (`-/+`) is the moment people understand why plans are reviewed.
- **LAB02** – the renames replace resources: a perfect motivation for `moved` in LAB04 and LAB06.
- **LAB03** – the state account uses `--allow-shared-key-access false`: Entra ID only. RBAC propagation can take a minute – warn people before the first `init`.
- **LAB04** – let the count trap happen on screen (Step 2) before showing `for_each`.
- **LAB06** – the plan without `moved` blocks (Step 4) wants to destroy the storage account: show it, then fix it. This is the most valuable 5 minutes of day 1.
- **LAB07** – the RDP rule in the drift step is deliberate: discuss who may change production outside of Git.
- **LAB08** – mocks need realistic ARM IDs (`tests/mocks/azurerm`); `override_resource` handles imports and random values. tflint warns about missing `prevent_destroy` on Key Vault – good discussion about lab vs. production.
- **LAB10** – show the leaky `random_password` in the state first, then the ephemeral/write-only version.
- **LAB11** – the federated credential subject is the most common error: compare it character by character with the token's subject.

## LAB12 – solutions

| # | Root cause | Error | Fix |
|---|---|---|---|
| BF1 | azurerm pinned to `~> 3.100`, code uses the 5.x `service_endpoint` block | `Unsupported block type` | `~> 5.12`, `terraform init -upgrade` |
| BF2 | `st-<prefix>-greengrid-reports-xxxx` – hyphens and > 24 characters | test: `invalid value for name` | `substr(replace(...,"-",""),0,24)` with a shorter pattern |
| BF3 | subnet `depends_on` the association, association references the subnet | `Cycle` | remove the `depends_on` |
| BF4 | `for_each = var.subnets` on a list of objects | `Invalid for_each argument` | `{ for s in var.subnets : s.name => s }` |
| BF5 | dynamic block uses `rule.*` | `Reference to undeclared resource` | `security_rule.*` or `iterator = rule` |
| BF6 | output built from a sensitive variable | `Output refers to sensitive values` | `sensitive = true` (or do not output secrets at all) |
| BF7 | ephemeral password in `value` | `Invalid use of ephemeral value` | `value_wo` + `value_wo_version` |
| BF8 | module call without `name` | `Missing required argument` | `name = "st${var.prefix}archive"` |

Reference fixes: `solutions/LAB12/fix.sh`.
