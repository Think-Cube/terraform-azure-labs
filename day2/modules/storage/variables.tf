variable "name_prefix" { type = string }
variable "location" { type = string }
variable "rg_name" { type = string }
variable "tags" { type = map(string) }
variable "subnet_ids" { type = list(string) }
