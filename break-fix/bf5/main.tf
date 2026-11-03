variable "prefix" {
  type = string
}

variable "nsg_rules" {
  type = map(object({
    priority = number
    port     = string
  }))
  default = {
    allow-https = { priority = 100, port = "443" }
    allow-api   = { priority = 110, port = "8080" }
  }
}

resource "azurerm_resource_group" "main" {
  name     = "rg-${var.prefix}-breakfix"
  location = "westeurope"
}

resource "azurerm_network_security_group" "app" {
  name                = "nsg-app-${var.prefix}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  dynamic "security_rule" {
    for_each = var.nsg_rules
    content {
      name                       = rule.key
      priority                   = rule.value.priority
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = rule.value.port
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }
}
