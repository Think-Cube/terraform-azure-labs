# LAB 09 – AzAPI: the whole Azure API, today

> **Story:** GreenGrid's security architect wants application security groups and asks for storage properties the azurerm provider does not show. Azure has them – in the Resource Manager REST API. AzAPI gives you that API in Terraform.

| | |
|---|---|
| **Duration** | ~35 min |
| **You create** | `azapi.tf`; you edit `versions.tf`, `providers.tf`, `outputs.tf`, the tests |
| **Solution** | `solutions/LAB09/` (or `./bin/catchup 9`) |

| | azurerm | AzAPI |
|---|---|---|
| Resources | curated, typed arguments | every ARM resource type and API version |
| New Azure features | when the provider adds them | the day the API ships |
| Validation | provider schema | embedded ARM schema (`schema_validation_enabled`) |
| Body | HCL arguments | the ARM JSON as an HCL object |

## Step 1 – Add the provider

`versions.tf` – add to `required_providers`:

```hcl
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.13"
    }
```

`providers.tf`:

```hcl
# Same credentials as azurerm (az login / OIDC) - no extra configuration
provider "azapi" {}
```

```bash
terraform init -upgrade -backend-config=backend.hcl
```

## Step 2 – A resource straight from its ARM schema

`azapi.tf`:

```hcl
resource "azapi_resource" "asg_app" {
  type      = "Microsoft.Network/applicationSecurityGroups@2024-05-01"
  name      = "asg-app-${local.name_suffix}"
  parent_id = azurerm_resource_group.main.id
  location  = azurerm_resource_group.main.location
  tags      = local.common_tags

  body = {
    properties = {}
  }

  response_export_values = ["properties.provisioningState"]
}
```

- `type` = resource type **@ API version** – look them up in the [Azure REST API reference](https://learn.microsoft.com/rest/api/azure/).
- `parent_id` follows the ARM hierarchy: resource group → resource → child resource.
- `body` is plain HCL in AzAPI 2.x – no `jsonencode()`; `output` is plain HCL too – no `jsondecode()`.

## Step 3 – Read anything

```hcl
data "azapi_resource" "storage" {
  type        = "Microsoft.Storage/storageAccounts@2024-01-01"
  resource_id = module.storage.id

  response_export_values = {
    tls          = "properties.minimumTlsVersion"
    access_tier  = "properties.accessTier"
    created_time = "properties.creationTime"
  }
}
```

Outputs:

```hcl
output "asg_provisioning_state" {
  description = "Read from the ARM response - no jsondecode() needed in AzAPI 2.x"
  value       = azapi_resource.asg_app.output.properties.provisioningState
}

output "storage_arm_properties" {
  description = "Storage properties read with AzAPI"
  value       = data.azapi_resource.storage.output
}
```

```bash
terraform apply -var-file=env/dev.tfvars
terraform output storage_arm_properties
```

✅ **Checkpoint:** `asg_provisioning_state = "Succeeded"`; the storage output shows `TLS1_2`, `Hot` and the creation time – `creationTime` is not an azurerm attribute.

## Step 4 – Keep the tests green

The tests from LAB08 now need a mock for azapi, otherwise `terraform test` asks for credentials:

```bash
mkdir -p tests/mocks/azapi
cp ../../solutions/LAB09/tests/mocks/azapi/azapi.tfmock.hcl tests/mocks/azapi/
```

Add to `tests/greengrid.tftest.hcl`:

```hcl
mock_provider "azapi" {
  source = "./tests/mocks/azapi"
}
```

```bash
terraform test
```

## Step 5 – azapi_update_resource (discussion)

`azapi_update_resource` PATCHes properties on a resource managed elsewhere – the classic way to set a property azurerm does not support yet:

```hcl
resource "azapi_update_resource" "example" {
  type        = "Microsoft.Storage/storageAccounts@2024-01-01"
  resource_id = module.storage.id
  body        = { properties = { someNewProperty = "value" } }
}
```

⚠️ If azurerm **also** manages that property, the two providers fight on every apply. Use it only for properties azurerm does not know – and replace it with the azurerm argument once the provider catches up.

## Bonus

- Convert the ASG to azurerm (`azurerm_application_security_group`) with a `moved` block – is that possible across providers? (No: use `removed` + `import`.)
- `azapi_resource_action` calls ARM actions, e.g. `listKeys` – why is that dangerous for the state?
- Export an existing resource as AzAPI code: `aztfexport resource --provider-name=azapi <resource id>`.

## Troubleshooting

| Symptom | Likely cause |
|---|---|
| `embedded schema validation failed` | property name or API version wrong – check the REST reference |
| `NoRegisteredProviderFound` for the API version | that version does not exist for this resource type |
| output is `null` | the path is not in `response_export_values` |
| tests ask for Azure credentials | `mock_provider "azapi"` missing |
