# The legacy resource group was created by hand in the portal years ago.
# The import block brings it under Terraform on the next apply - reviewed in the plan first.
import {
  to = azurerm_resource_group.legacy
  id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/rg-${var.prefix}-legacy"
}

resource "azurerm_resource_group" "legacy" {
  name     = "rg-${var.prefix}-legacy"
  location = var.location
  tags     = merge(local.common_tags, { legacy = "true" })
}

# The README blob now belongs to the data team: drop it from the state, keep it in Azure
removed {
  from = azurerm_storage_blob.readme

  lifecycle {
    destroy = false
  }
}
