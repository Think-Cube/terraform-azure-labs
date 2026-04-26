# LAB 7 (Bonus) — Drift Detection + terraform import

## Part A — Drift detection (portal change vs code)
1) Deploy (if needed):
```bash
cd day2/infra
terraform init
terraform apply -var-file=env/dev.tfvars
```
2) In Azure Portal: change a tag on the Resource Group (create drift).
3) Detect drift:
```bash
terraform plan -var-file=env/dev.tfvars
```
4) Decide source of truth:
- apply to revert portal drift
- or update code and apply to keep the change

## Part B — Import an existing Resource Group
1) Create RG outside Terraform:
```bash
az group create -n rg-shared-network -l westeurope
```
2) Create `import-demo.tf` with a data source + output:
```hcl
data "azurerm_resource_group" "existing" {
  name = "rg-shared-network"
}

output "existing_rg_location" {
  value = data.azurerm_resource_group.existing.location
}
```
3) Add a managed resource block:
```hcl
resource "azurerm_resource_group" "imported" {
  name     = "rg-shared-network"
  location = "westeurope"
}
```
4) Import:
```bash
SUB_ID=$(az account show --query id -o tsv)
terraform import -var-file=env/dev.tfvars \
  azurerm_resource_group.imported \
  /subscriptions/$SUB_ID/resourceGroups/rg-shared-network
```
5) Inspect:
```bash
terraform state show azurerm_resource_group.imported
terraform plan -var-file=env/dev.tfvars
```

## Done when
- you can create and detect drift
- you can import and reconcile an existing RG
