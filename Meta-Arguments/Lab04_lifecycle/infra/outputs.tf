output "resource_group_name"  { value = azurerm_resource_group.rg.name }
output "storage_account_name" { value = azurerm_storage_account.sa.name }
output "vnet_address_space"   { value = azurerm_virtual_network.vnet.address_space }
