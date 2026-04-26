variable "name_prefix" { type = string }
variable "location" { type = string }
variable "rg_name" { type = string }
variable "tags" { type = map(string) }
variable "address_space" { type = list(string) }
variable "subnets" { type = list(object({ name = string, cidr = string })) }
