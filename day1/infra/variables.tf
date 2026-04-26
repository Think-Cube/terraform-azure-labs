variable "project" {
  type        = string
  description = "Short project code used in names (3-12 chars)"
  validation {
    condition     = length(var.project) >= 3 && length(var.project) <= 12
    error_message = "project must be 3-12 characters"
  }
}

variable "environment" {
  type        = string
  description = "dev/staging/prod"
  default     = "staging"
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
