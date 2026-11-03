output "vnet_id" {
  value = azurerm_virtual_network.this.id
}

output "subnet_ids" {
  description = "Subnet IDs keyed by subnet name"
  value       = { for name, s in azurerm_subnet.this : name => s.id }
}
