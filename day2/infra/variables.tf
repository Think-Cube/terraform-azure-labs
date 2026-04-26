variable "project" {
  type = string
}

variable "environment" {
  type = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod"
  }
}

variable "location" {
  type = string
}

variable "address_space" {
  type    = list(string)
  default = ["10.10.0.0/16"]
}

variable "subnets" {
  type = list(object({
    name = string
    cidr = string
  }))

  validation {
    condition     = length(var.subnets) >= 2
    error_message = "Provide at least 2 subnets"
  }

  validation {
    condition = alltrue([
      for s in var.subnets : length(s.name) >= 3
    ])
    error_message = "Each subnet name must be at least 3 characters long"
  }

  validation {
    condition = alltrue([
      for s in var.subnets : can(cidrnetmask(s.cidr))
    ])
    error_message = "Each subnet CIDR must be valid (e.g. 10.0.0.0/24)"
  }
}

variable "nsg_rules" {
  description = "Map of NSG rules keyed by rule name"
  type = map(object({
    priority = number
    port     = number
    source   = string
  }))

  validation {
    condition = alltrue([
      for r in var.nsg_rules : r.port > 0 && r.port <= 65535
    ])
    error_message = "Ports must be between 1 and 65535"
  }

  validation {
    condition = alltrue([
      for r in var.nsg_rules : r.priority >= 100 && r.priority <= 4096
    ])
    error_message = "Priority must be between 100 and 4096"
  }
}