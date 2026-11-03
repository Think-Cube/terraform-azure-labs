locals {
  name_suffix = "${var.prefix}-greengrid-${var.environment}"

  # Storage account: 3-24 characters, lowercase letters and digits only
  storage_name = substr(lower(replace("st${var.prefix}gg${var.environment}${random_string.suffix.result}", "-", "")), 0, 24)

  is_prod = var.environment == "prod"

  common_tags = merge(
    {
      project     = "greengrid"
      environment = var.environment
      owner       = var.owner
      managed_by  = "terraform"
    },
    var.extra_tags,
  )
}
