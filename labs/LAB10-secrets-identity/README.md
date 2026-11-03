# LAB 10 – Secrets and identities without leaks

> **Story:** The ingestion service needs a database password and access to the meter data. Last audit found passwords in a Terraform state file – that must never happen again. Today: no secret in the state, no password for the service at all.

| | |
|---|---|
| **Duration** | ~45 min |
| **You create** | `secrets.tf`; you edit `outputs.tf` |
| **Solution** | `solutions/LAB10/` (or `./bin/catchup 10`) |

| Problem | Answer |
|---|---|
| a generated password ends up in the state | **ephemeral** resource + **write-only** attribute |
| an app needs credentials to reach Azure | **managed identity** + RBAC role assignment |
| a pipeline needs credentials | **workload identity federation (OIDC)** – LAB11 |
| a secret must be stored | **Key Vault** with RBAC authorization |

## Step 1 – Key Vault with RBAC

`secrets.tf`:

```hcl
resource "azurerm_key_vault" "main" {
  name                       = "kv-${var.prefix}-gg-${random_string.suffix.result}"
  resource_group_name        = azurerm_resource_group.main.name
  location                   = azurerm_resource_group.main.location
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  rbac_authorization_enabled = true # Azure RBAC instead of access policies
  purge_protection_enabled   = false
  soft_delete_retention_days = 7
  tags                       = local.common_tags
}

resource "azurerm_role_assignment" "me_kv_secrets_officer" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}
```

> `purge_protection_enabled = false` only because this is a lab and the vault is destroyed at the end. In production: `true`.

## Step 2 – The old way leaks

Add a classic secret and look at the state:

```hcl
resource "random_password" "leaky" {
  length = 24
}
```

```bash
terraform apply -var-file=env/dev.tfvars -target=random_password.leaky
terraform state pull | grep -A3 '"type": "random_password"' | head; terraform state pull | grep '"result"'
```

✅ **Checkpoint:** the password is in the state in plain text. Everybody who can read the state blob can read it. Delete the resource block again.

## Step 3 – Ephemeral + write-only

```hcl
# Ephemeral: generated during plan/apply, never written to the plan file or the state
ephemeral "random_password" "db_admin" {
  length  = 24
  special = true
}

resource "azurerm_key_vault_secret" "db_admin_password" {
  name         = "db-admin-password"
  key_vault_id = azurerm_key_vault.main.id

  # write-only: sent to Azure, not stored in the state; bump the version to rotate
  value_wo         = ephemeral.random_password.db_admin.result
  value_wo_version = 1

  depends_on = [azurerm_role_assignment.me_kv_secrets_officer]
}
```

```bash
terraform apply -var-file=env/dev.tfvars
terraform state pull | grep -c db_admin            # the resource is there…
terraform state pull | grep '"value_wo"'            # …the value is null
az keyvault secret show --vault-name <kv-name> -n db-admin-password --query value -o tsv
```

✅ **Checkpoint:** Key Vault has the password; the state does not. To rotate: `value_wo_version = 2`, apply.

| Concept | Terraform | Stored in state? |
|---|---|---|
| `sensitive = true` | 0.14+ | yes – only hidden in output |
| `ephemeral` resource / variable / output | 1.10+ | no |
| write-only attribute (`*_wo`) | 1.11+ | no |

## Step 4 – A managed identity for the ingestion service

```hcl
# Identity for the GreenGrid ingestion service - no passwords at all
resource "azurerm_user_assigned_identity" "ingest" {
  name                = "id-ingest-${local.name_suffix}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  tags                = local.common_tags
}

resource "azurerm_role_assignment" "ingest_blob_reader" {
  scope                = module.storage.id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azurerm_user_assigned_identity.ingest.principal_id
  principal_type       = "ServicePrincipal"
}

resource "azurerm_role_assignment" "ingest_secrets_user" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.ingest.principal_id
  principal_type       = "ServicePrincipal"
}
```

Outputs `key_vault_uri` (`azurerm_key_vault.main.vault_uri`) and `ingest_identity_client_id` (`azurerm_user_assigned_identity.ingest.client_id`).

✅ **Checkpoint:** `az role assignment list --assignee <principal id> -o table` shows *Storage Blob Data Reader* and *Key Vault Secrets User* – least privilege, scoped to one storage account and one vault.

> `principal_type = "ServicePrincipal"` avoids a race: without it, Azure may reject the assignment while the new identity is still replicating in Entra ID.

| Identity | Lifecycle | Use for |
|---|---|---|
| system-assigned | tied to one resource | one VM/app, simple |
| user-assigned | independent, reusable | shared by several resources, pre-created before the app |
| workload identity federation | no secret, trusts an external token (GitHub, AKS, Azure DevOps) | pipelines and Kubernetes workloads |

## Step 5 – Tests

`terraform test` – the mocks already know `azurerm_key_vault` and `azurerm_user_assigned_identity`. Add an assertion that the secret uses `value_wo` (hint: `azurerm_key_vault_secret.db_admin_password.value == null`).

## Troubleshooting

| Symptom | Likely cause |
|---|---|
| `Forbidden … does not have secrets set permission` | Secrets Officer role not propagated yet – apply again after a minute |
| `VaultAlreadyExists` / `soft deleted` | a vault with that name is in soft-delete – `az keyvault purge -n <name>` or another suffix |
| `Invalid use of ephemeral value` | ephemeral values only go into write-only attributes, ephemeral outputs/variables or provider blocks |
| `value_wo` change not applied | write-only values are not compared – bump `value_wo_version` |
