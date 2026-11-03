resource "azurerm_resource_group" "main" {
  name     = "rg-${local.name_suffix}"
  location = var.location
  tags     = local.common_tags
}

# Storage account names are global: add a random suffix
resource "random_string" "suffix" {
  length  = 4
  upper   = false
  special = false
}

module "network" {
  source = "./modules/network"

  name_suffix         = local.name_suffix
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  tags                = local.common_tags
  address_space       = var.address_space
  subnets             = var.subnets
  nsg_rules           = var.nsg_rules
}

module "storage" {
  source = "./modules/storage"

  name                   = local.storage_name
  resource_group_name    = azurerm_resource_group.main.name
  location               = azurerm_resource_group.main.location
  tags                   = local.common_tags
  replication_type       = local.is_prod ? "ZRS" : "LRS"
  zones                  = var.data_zones
  enable_archive         = var.enable_archive
  default_network_action = local.is_prod ? "Deny" : "Allow"
  allowed_ips            = var.allowed_ips
  allowed_subnet_ids     = [module.network.subnet_ids["app"]]
}

# You need a data-plane role to upload blobs with Entra ID
resource "azurerm_role_assignment" "me_blob_contributor" {
  scope                = module.storage.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_storage_blob" "readme" {
  name                 = "README.txt"
  storage_container_id = module.storage.container_ids["raw"]
  type                 = "Block"
  source_content       = "GreenGrid raw meter readings land here.\n"

  depends_on = [azurerm_role_assignment.me_blob_contributor]
}
