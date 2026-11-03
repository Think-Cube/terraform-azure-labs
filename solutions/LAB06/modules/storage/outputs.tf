output "id" {
  value = azurerm_storage_account.this.id
}

output "name" {
  value = azurerm_storage_account.this.name
}

output "primary_blob_endpoint" {
  value = azurerm_storage_account.this.primary_blob_endpoint
}

output "container_ids" {
  description = "Container IDs keyed by zone"
  value       = { for zone, c in azurerm_storage_container.zone : zone => c.id }
}
