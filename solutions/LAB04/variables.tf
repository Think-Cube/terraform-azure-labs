variable "prefix" {
  type        = string
  description = "Your personal prefix (2-8 lowercase letters/digits) - unique in the shared subscription"

  validation {
    condition     = can(regex("^[a-z0-9]{2,8}$", var.prefix))
    error_message = "prefix must be 2-8 lowercase letters or digits."
  }
}

variable "environment" {
  type        = string
  description = "Environment name"

  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "environment must be dev, test or prod."
  }
}

variable "location" {
  type        = string
  description = "Azure region"
  default     = "westeurope"

  validation {
    condition     = contains(["westeurope", "northeurope", "swedencentral", "polandcentral"], var.location)
    error_message = "Use an EU region approved by GreenGrid: westeurope, northeurope, swedencentral or polandcentral."
  }
}

variable "owner" {
  type        = string
  description = "Team or person responsible for the resources"
  default     = "platform-team"
}

variable "extra_tags" {
  type        = map(string)
  description = "Additional tags merged into the standard tags"
  default     = {}
}

variable "data_zones" {
  type        = set(string)
  description = "Data lake zones - one blob container each"
  default     = ["raw", "curated", "reports"]
}

variable "enable_archive" {
  type        = bool
  description = "Create the archive container"
  default     = false
}
