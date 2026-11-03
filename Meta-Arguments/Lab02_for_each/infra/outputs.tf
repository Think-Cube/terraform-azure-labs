output "resource_group_name" { value = azurerm_resource_group.rg.name }
output "vnet_ids"            { value = { for k, v in azurerm_virtual_network.vnet : k => v.id } }
output "extra_rg_names"      { value = { for k, v in azurerm_resource_group.extra : k => v.name } }
