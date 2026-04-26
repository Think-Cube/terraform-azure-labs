# LAB 2 — Remote State (Azure Backend) + Migration

**Goal:** Create an Azure Storage backend and migrate local state to remote.

## 1) Bootstrap backend (Azure CLI)
```bash
RG="rg-tfstate"
LOC="westeurope"
SA="sttfstate$RANDOM$RANDOM"
CONTAINER="tfstate"

az group create -n $RG -l $LOC
az storage account create -n $SA -g $RG -l $LOC \
  --sku Standard_LRS --min-tls-version TLS1_2 --https-only true
az storage container create -n $CONTAINER --account-name $SA

echo "Backend Storage Account: $SA"
```

## 2) Configure backend.tf
- Copy `backend.tf.example` → `backend.tf`
- Paste the storage account name into `storage_account_name`

## 3) Migrate state
```bash
cd day1/infra
terraform init
```
When prompted, type `yes`.

## 4) Verify state blob
```bash
az storage blob list --account-name <BACKEND_SA> --container-name tfstate -o table
```

## 5) Confirm plan works
```bash
terraform plan -var-file=env/staging.tfvars
```

## Done when
- state is in blob storage
- init migrated state
- plan works using remote backend
