output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "storage_account_name" {
  description = "Name of the data storage account"
  value       = azurerm_storage_account.data.name
}

output "storage_blob_endpoint" {
  description = "Blob endpoint - used by the GreenGrid ingestion service"
  value       = azurerm_storage_account.data.primary_blob_endpoint
}

output "tags" {
  description = "Tags applied to every resource"
  value       = local.common_tags
}

output "container_names" {
  description = "Blob containers per data zone"
  value       = { for zone, c in azurerm_storage_container.zone : zone => c.name }
}
