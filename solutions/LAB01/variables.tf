variable "prefix" {
  type        = string
  description = "Your personal prefix (2-8 lowercase letters/digits) - unique in the shared subscription"
}

variable "location" {
  type        = string
  description = "Azure region"
  default     = "westeurope"
}
