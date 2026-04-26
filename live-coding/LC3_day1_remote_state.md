# LC3 — Remote State + Migration (Azure Backend)

**Outcome:** participants see local→remote state migration.

## Steps
### Bootstrap backend
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

### Configure backend
- copy `backend.tf.example` → `backend.tf`
- paste `$SA` into `storage_account_name`

### Migrate
```bash
cd day1/infra
terraform init
```
Type `yes` when prompted.

### Verify blob
```bash
az storage blob list --account-name $SA --container-name tfstate -o table
```

### Confirm plan works
```bash
terraform plan -var-file=env/staging.tfvars
```

### Optional locking demo
- terminal A: start `terraform apply` (pause at approval)
- terminal B: run `terraform apply` and show lock error

## Teaching points
- remote state enables collaboration
- locking prevents parallel applies
