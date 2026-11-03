locals {
  name_prefix = "${var.project}-${var.environment}-${random_string.suffix.result}"

  storage_name = substr(
    replace(lower("st${local.name_prefix}"), "-", ""),
    0, 24
  )

  common_tags = {
    project = var.project
    env     = var.environment
    managed = "terraform"
  }
}
