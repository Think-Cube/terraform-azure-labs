# AzAPI talks to the Azure Resource Manager REST API directly: any resource type, any API version,
# available the day Azure ships it. The body is plain HCL (AzAPI 2.x) - no jsonencode().

# An application security group, created straight from its ARM schema
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

# Read any ARM resource - here the storage account, including properties azurerm does not expose
data "azapi_resource" "storage" {
  type        = "Microsoft.Storage/storageAccounts@2024-01-01"
  resource_id = module.storage.id

  response_export_values = {
    tls          = "properties.minimumTlsVersion"
    access_tier  = "properties.accessTier"
    created_time = "properties.creationTime"
  }
}
