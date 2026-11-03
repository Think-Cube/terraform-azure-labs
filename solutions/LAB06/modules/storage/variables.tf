variable "name" {
  type        = string
  description = "Storage account name (3-24 lowercase letters and digits)"

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.name))
    error_message = "Storage account names are 3-24 lowercase letters and digits."
  }
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "replication_type" {
  type    = string
  default = "LRS"
}

variable "zones" {
  type        = set(string)
  description = "One blob container per data zone"
  default     = []
}

variable "enable_archive" {
  type    = bool
  default = false
}

variable "default_network_action" {
  type    = string
  default = "Allow"
}

variable "allowed_ips" {
  type    = list(string)
  default = []
}

variable "allowed_subnet_ids" {
  type    = list(string)
  default = []
}
