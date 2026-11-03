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

variable "address_space" {
  type        = list(string)
  description = "Address space of the GreenGrid virtual network"
  default     = ["10.20.0.0/16"]

  validation {
    condition     = alltrue([for cidr in var.address_space : can(cidrhost(cidr, 0))])
    error_message = "Every address_space entry must be a valid CIDR, e.g. 10.20.0.0/16."
  }
}

variable "subnets" {
  type = map(object({
    cidr              = string
    service_endpoints = optional(list(string), [])
  }))
  description = "Subnets keyed by name"
  default = {
    app  = { cidr = "10.20.1.0/24", service_endpoints = ["Microsoft.Storage"] }
    data = { cidr = "10.20.2.0/24" }
  }
}

variable "nsg_rules" {
  type = map(object({
    priority = number
    port     = string
    source   = string
    access   = optional(string, "Allow")
    protocol = optional(string, "Tcp")
  }))
  description = "Inbound rules for the app subnet, keyed by rule name"
  default = {
    allow-https = { priority = 100, port = "443", source = "Internet" }
    allow-api   = { priority = 110, port = "8080", source = "VirtualNetwork" }
  }

  validation {
    condition     = alltrue([for r in values(var.nsg_rules) : r.priority >= 100 && r.priority <= 4096])
    error_message = "NSG rule priorities must be between 100 and 4096."
  }
}

variable "allowed_ips" {
  type        = list(string)
  description = "Public IPs allowed to reach the storage account (e.g. your laptop)"
  default     = []
}
