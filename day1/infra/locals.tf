locals {
  name_prefix = "${var.project}-${var.environment}"

  # Storage account: lowercase, no hyphens, max 24 chars
  storage_name = substr(
    replace(lower("st${local.name_prefix}001"), "-", ""),
    0,
    24
  )

  common_tags = {
    project  = var.project
    env      = var.environment
    managed  = "terraform"
    owner    = "platform-team"
    tenantId = data.azurerm_client_config.current.tenant_id
  }
}
