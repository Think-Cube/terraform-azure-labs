resource "azurerm_subnet_network_security_group_association" "assoc" {
  for_each                  = module.network.subnet_ids
  subnet_id                 = each.value
  network_security_group_id = module.security.nsg_id

  depends_on = [azurerm_resource_group.rg, module.network, module.security, module.storage]
}

module "storage" {
  source      = "../modules/storage"
  name_prefix = local.name_prefix
  location    = var.location
  rg_name     = azurerm_resource_group.rg.name
  tags        = local.common_tags

  subnet_ids = values(module.network.subnet_ids)

  depends_on = [azurerm_resource_group.rg, module.network]
}
