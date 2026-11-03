variable "prefix" {
  type = string
}

variable "sql_admin_password" {
  type      = string
  sensitive = true
}

resource "azurerm_resource_group" "main" {
  name     = "rg-${var.prefix}-breakfix"
  location = "westeurope"
}

output "connection_string" {
  description = "Handed to the reporting team"
  value       = "Server=tcp:sql-${var.prefix}.database.windows.net;User ID=greengrid;Password=${var.sql_admin_password}"
}
