locals {
  name_prefix = "${var.project}-${var.environment}-${random_string.suffix.result}"

  common_tags = {
    project = var.project
    env     = var.environment
    managed = "terraform"
  }
}
