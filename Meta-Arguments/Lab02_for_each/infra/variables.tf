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

variable "vnets" {
  type = map(object({
    address_space = string
    tier          = string
  }))
  description = "Map of VNets to create — key becomes part of the resource name"
  default = {
    shared = { address_space = "10.0.0.0/16", tier = "shared" }
    dev    = { address_space = "10.1.0.0/16", tier = "workload" }
    prod   = { address_space = "10.2.0.0/16", tier = "workload" }
  }
}

variable "extra_locations" {
  type        = list(string)
  description = "Extra regions — each becomes a separate Resource Group (demonstrates toset)"
  default     = ["northeurope"]
}
