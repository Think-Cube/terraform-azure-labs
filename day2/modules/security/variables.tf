variable "name_prefix" { type = string }
variable "location" { type = string }
variable "rg_name" { type = string }
variable "tags" { type = map(string) }
variable "nsg_rules" { type = map(object({ priority = number, port = number, source = string })) }
