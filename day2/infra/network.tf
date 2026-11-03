module "network" {
  source      = "../modules/network"
  name_prefix = local.name_prefix
  location    = var.location
  rg_name     = azurerm_resource_group.rg.name
  tags        = local.common_tags

  address_space = var.address_space
  subnets       = var.subnets

  depends_on = [azurerm_resource_group.rg]
}

module "security" {
  source      = "../modules/security"
  name_prefix = local.name_prefix
  location    = var.location
  rg_name     = azurerm_resource_group.rg.name
  tags        = local.common_tags

  nsg_rules = var.nsg_rules

  depends_on = [azurerm_resource_group.rg, module.network]
}