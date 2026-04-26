resource "azurerm_resource_group" "rg" {
  name     = "rg-${local.name_prefix}"
  location = var.location
  tags     = local.common_tags
}

module "network" {
  source      = "../modules/network"
  name_prefix = local.name_prefix
  location    = var.location
  rg_name     = azurerm_resource_group.rg.name
  tags        = local.common_tags

  address_space = var.address_space
  subnets       = var.subnets
}

module "security" {
  source      = "../modules/security"
  name_prefix = local.name_prefix
  location    = var.location
  rg_name     = azurerm_resource_group.rg.name
  tags        = local.common_tags

  nsg_rules = var.nsg_rules
}

resource "azurerm_subnet_network_security_group_association" "assoc" {
  for_each = module.network.subnet_ids
  subnet_id                 = each.value
  network_security_group_id = module.security.nsg_id
}

module "storage" {
  source      = "../modules/storage"
  name_prefix = local.name_prefix
  location    = var.location
  rg_name     = azurerm_resource_group.rg.name
  tags        = local.common_tags

  subnet_ids = values(module.network.subnet_ids)
}
