variable "project" {
  type        = string
  description = "Short project code used in resource names (3-12 chars, lowercase)"
  validation {
    condition     = can(regex("^[a-z0-9]{3,12}$", var.project))
    error_message = "project must be 3-12 lowercase letters/digits, no hyphens"
  }
}

variable "environment" {
  type        = string
  description = "dev / staging / prod"
  default     = "dev"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be dev, staging, or prod"
  }
}

variable "location" {
  type        = string
  description = "Azure region"
  default     = "westeurope"
}

variable "vnet_count" {
  type        = number
  description = "Number of VNets to create (1-5)"
  default     = 3
  validation {
    condition     = var.vnet_count >= 1 && var.vnet_count <= 5
    error_message = "vnet_count must be between 1 and 5"
  }
}
