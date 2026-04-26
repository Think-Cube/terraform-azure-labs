locals {
  name_prefix = "${var.project}-${var.environment}"
  common_tags = {
    project = var.project
    env     = var.environment
    owner   = "platform-team"
    managed = "terraform"
  }
}
