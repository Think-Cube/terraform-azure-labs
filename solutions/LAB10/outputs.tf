output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "storage_account_name" {
  description = "Name of the data storage account"
  value       = module.storage.name
}

output "storage_blob_endpoint" {
  description = "Blob endpoint - used by the GreenGrid ingestion service"
  value       = module.storage.primary_blob_endpoint
}

output "subnet_ids" {
  description = "Subnet IDs keyed by subnet name"
  value       = module.network.subnet_ids
}

output "tags" {
  description = "Tags applied to every resource"
  value       = local.common_tags
}

output "asg_provisioning_state" {
  description = "Read from the ARM response - no jsondecode() needed in AzAPI 2.x"
  value       = azapi_resource.asg_app.output.properties.provisioningState
}

output "storage_arm_properties" {
  description = "Storage properties read with AzAPI"
  value       = data.azapi_resource.storage.output
}

output "key_vault_uri" {
  description = "Key Vault with the GreenGrid secrets"
  value       = azurerm_key_vault.main.vault_uri
}

output "ingest_identity_client_id" {
  description = "Client ID of the ingestion service identity"
  value       = azurerm_user_assigned_identity.ingest.client_id
}
