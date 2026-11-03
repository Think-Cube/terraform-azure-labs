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

variable "vnet_address_space" {
  type        = string
  description = "VNet address space — change this to trigger a replacement"
  default     = "10.0.0.0/16"
}
