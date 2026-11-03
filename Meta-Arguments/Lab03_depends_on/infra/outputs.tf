output "storage_account_name"    { value = azurerm_storage_account.sa.name }
# This value comes from the data source — it can only be read after depends_on resolves
output "primary_blob_endpoint"  { value = data.azurerm_storage_account.sa_info.primary_blob_endpoint }
