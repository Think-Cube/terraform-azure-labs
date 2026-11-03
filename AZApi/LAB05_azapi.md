# LAB 5 — azapi

**Goal:** Use the `azapi` provider to call Azure REST APIs directly — for resources or properties not yet in `azurerm`.

## Why azapi?

`azurerm` wraps Azure resources in friendly HCL blocks, but it always lags behind the Azure API.
New resource types and new properties appear in Azure first — `azapi` lets you use them immediately.

| resource | use when |
|---|---|
| `azapi_resource` | create a resource type not yet in azurerm |
| `azapi_update_resource` | patch properties on an existing resource that azurerm doesn't expose |

## Start
```bash
cd Lab05_azapi/infra
terraform init
terraform plan  -var-file=env/dev.tfvars
terraform apply -var-file=env/dev.tfvars
```

## Tasks

### 1 — Compare azapi vs azurerm in the plan
Look at `azapi_resource.vnet` in the plan output.
Terraform shows the raw JSON body — not friendly HCL attributes.
This is because azapi passes the body straight to the Azure REST API.

### 2 — Add a subnet via azapi_resource
Add this block to `main.tf`:
```hcl
resource "azapi_resource" "subnet" {
  type      = "Microsoft.Network/virtualNetworks/subnets@2023-04-01"
  name      = "subnet-main"
  parent_id = azapi_resource.vnet.id

  body = jsonencode({
    properties = {
      addressPrefix = "10.0.1.0/24"
    }
  })
}
```
Plan and apply. Notice: `parent_id` is the VNet, not the RG — it follows the ARM hierarchy.

### 3 — Verify azapi_update_resource in the portal
Portal → Storage Account → Configuration → look for **"Allowed copy scope"**.
It should be set to `AAD` — applied by `azapi_update_resource`, not by azurerm.

### 4 — Find the API schema (optional)
Open [Azure REST API docs](https://learn.microsoft.com/en-us/rest/api/storagerp/storage-accounts/create)
and find `allowedCopyScope` in the schema.
This is how you discover what properties you can set via azapi.

## Cleanup
```bash
terraform destroy -var-file=env/dev.tfvars
```

## Done when
- VNet created via `azapi_resource`
- subnet added as a child resource (`parent_id = vnet`)
- portal confirms `allowedCopyScope = AAD` on the Storage Account
