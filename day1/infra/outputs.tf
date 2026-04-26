output "resource_group_name" { value = azurerm_resource_group.rg.name }
output "storage_account_name" { value = azurerm_storage_account.sa.name }
output "subscription_id" { value = data.azurerm_client_config.current.subscription_id }
output "tenant_id" { value = data.azurerm_client_config.current.tenant_id }
