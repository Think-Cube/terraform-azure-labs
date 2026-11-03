# Resources that moved into modules in LAB06 - Terraform updates the state instead of recreating them.
# The count -> for_each moves from LAB04 are gone: once everybody has applied them, they can be deleted.

moved {
  from = azurerm_virtual_network.main
  to   = module.network.azurerm_virtual_network.this
}

moved {
  from = azurerm_subnet.this
  to   = module.network.azurerm_subnet.this
}

moved {
  from = azurerm_network_security_group.app
  to   = module.network.azurerm_network_security_group.app
}

moved {
  from = azurerm_subnet_network_security_group_association.app
  to   = module.network.azurerm_subnet_network_security_group_association.app
}

moved {
  from = azurerm_storage_account.data
  to   = module.storage.azurerm_storage_account.this
}

moved {
  from = azurerm_storage_container.zone
  to   = module.storage.azurerm_storage_container.zone
}

moved {
  from = azurerm_storage_container.archive
  to   = module.storage.azurerm_storage_container.archive
}
