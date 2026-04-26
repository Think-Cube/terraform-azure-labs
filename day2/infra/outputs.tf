output "rg_name" { value = azurerm_resource_group.rg.name }
output "vnet_id" { value = module.network.vnet_id }
output "subnet_ids" { value = module.network.subnet_ids }
output "nsg_id" { value = module.security.nsg_id }
output "storage_account_name" { value = module.storage.storage_account_name }
