# LAB 12 – Break-fix challenge 🔧

> **Story:** Friday afternoon. Eight GreenGrid teams opened tickets: *"Terraform is broken!"*. Terraform is fine – every ticket is a mistake in the code. Fix them like an on-call engineer: read the error, form a hypothesis, change one thing, verify.

| | |
|---|---|
| **Duration** | ~40 min (pairs work great) |
| **You use** | `break-fix/bf1` … `bf8`, `./bin/check-breakfix.sh` |

No Azure access needed: every scenario is checked with `terraform validate` and `terraform test` against mocked providers.

```bash
./bin/check-breakfix.sh          # 0 / 8 - your starting point
cd break-fix/bf1
terraform init -backend=false
terraform validate
terraform test
```

Fix the code in the scenario folder; re-run `./bin/check-breakfix.sh` (or `./bin/check-breakfix.sh 3` for one scenario). Reset everything with `git checkout -- break-fix`.

## The tickets

| # | Ticket | Hint (only if stuck) |
|---|---|---|
| BF1 | *Networking: "Unsupported block type" – the code is straight from the docs!* | Which provider version do the docs describe, which one is pinned? After changing it: `terraform init -upgrade`. |
| BF2 | *Reporting: validate is green, but the storage account is rejected* | Azure naming rules for storage accounts. |
| BF3 | *Platform: "Cycle" – we only added a dependency to be safe* | Who already depends on whom? |
| BF4 | *Network team: our subnet list worked in the old module* | What can `for_each` iterate over? |
| BF5 | *Security: dynamic NSG rules – "Reference to undeclared resource"* | What is the iterator called inside a dynamic block? |
| BF6 | *Data: we only want to hand the connection string to the reporting team* | Where does the password come from? |
| BF7 | *Partners: generate an API key and store it in Key Vault – "Invalid use of ephemeral value"* | Which attributes accept ephemeral values? |
| BF8 | *Archive: "Missing required argument" in the module call* | Read the module's `variables.tf`. |

✅ **Goal:** `./bin/check-breakfix.sh` reports **8 / 8**.

## Wrap-up

- Which errors did `terraform validate` catch, which only `terraform test` – and which would only have appeared during `apply` in Azure without the tests?
- Which of these would tflint (LAB08) have reported?
- What goes into your team's pull-request checklist?
