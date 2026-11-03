locals {
  name_prefix = "${var.project}-${var.environment}-${random_string.suffix.result}"

  # Storing the name in a local means the storage account resource and the
  # data source below both refer to a plain string — no implicit dependency
  # is created between them, so depends_on becomes necessary.
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
