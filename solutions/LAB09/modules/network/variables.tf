variable "name_suffix" {
  type        = string
  description = "Suffix used in resource names, e.g. jk-greengrid-dev"
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

variable "address_space" {
  type = list(string)
}

variable "subnets" {
  type = map(object({
    cidr              = string
    service_endpoints = optional(list(string), [])
  }))
}

variable "nsg_rules" {
  type = map(object({
    priority = number
    port     = string
    source   = string
    access   = optional(string, "Allow")
    protocol = optional(string, "Tcp")
  }))
  description = "Inbound rules for the NSG"
  default     = {}
}

variable "nsg_subnet" {
  type        = string
  description = "Key of the subnet that gets the NSG"
  default     = "app"
}
