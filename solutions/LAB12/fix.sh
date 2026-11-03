#!/usr/bin/env bash
# Reference fixes for the LAB12 break-fix challenge (instructor).  Run from the repository root:
#   bash solutions/LAB12/fix.sh && ./bin/check-breakfix.sh        (undo: git checkout break-fix)
set -euo pipefail
B=break-fix
# BF1 - code is written for azurerm 5 (service_endpoint block): pin the right major version
sed -i 's/version = "~> 3.100"/version = "~> 5.12"/' $B/bf1/versions.tf
rm -f $B/bf1/.terraform.lock.hcl
# BF2 - storage account names: lowercase letters and digits, max 24
sed -i 's/storage_name = "st-${var.prefix}-greengrid-reports-${random_string.suffix.result}"/storage_name = substr(replace("st${var.prefix}ggrep${random_string.suffix.result}", "-", ""), 0, 24)/' $B/bf2/main.tf
# BF3 - the association already depends on the subnet; depends_on in the other direction is a cycle
sed -i '/the NSG must be ready before the subnet/d; /depends_on = \[azurerm_subnet_network_security_group_association.app\]/d' $B/bf3/main.tf
# BF4 - for_each needs a map (or a set of strings): key the list by name
sed -i 's/for_each             = var.subnets/for_each             = { for s in var.subnets : s.name => s }/' $B/bf4/main.tf
# BF5 - inside a dynamic block the iterator is named after the block (or set it with iterator = rule)
sed -i 's/    for_each = var.nsg_rules/    for_each = var.nsg_rules\n    iterator = rule/' $B/bf5/main.tf
# BF6 - an output built from a sensitive value must be marked sensitive
sed -i 's/  description = "Handed to the reporting team"/  description = "Handed to the reporting team"\n  sensitive   = true/' $B/bf6/main.tf
# BF7 - ephemeral values only go into write-only attributes
sed -i 's/  value        = ephemeral.random_password.api_key.result/  value_wo         = ephemeral.random_password.api_key.result\n  value_wo_version = 1/' $B/bf7/main.tf
# BF8 - the module needs a name
sed -i 's|  source = "./modules/storage"|  source = "./modules/storage"\n\n  name                = "st${var.prefix}archive"|' $B/bf8/main.tf
for d in $B/bf*; do terraform fmt "$d" >/dev/null; done
