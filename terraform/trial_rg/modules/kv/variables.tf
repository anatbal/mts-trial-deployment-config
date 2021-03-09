variable "rg_name" {
  type        = string
  description = "Resource group"

  validation {
    # https://github.com/toddkitta/azure-content/blob/master/articles/guidance/guidance-naming-conventions.md
    condition     = length(var.rg_name) > 3 && length(var.rg_name) < 64 && can(regex("[a-z,0-9,-,_]", var.rg_name))
    error_message = "The rg_name must consist of lowercase letters, numbers underscores, and hyphens only."
  }
}

variable "tenant_id" {
  type        = string
  description = "Tenant id"
}

variable "trial_name" {
  type        = string
  description = "Trial name. Use only lowercase letters and numbers"
}

variable "environment" {
  type        = string
  description = "Environment name, e.g. 'dev' or 'stage'"
  default     = "dev"
}

variable "location" {
  type        = string
  description = "Azure region where to create resources."
  default     = "uksouth"
}

variable "vnet_id" {
  type        = string
  description = "The vnet to be integrated into."
}

variable "subnet_id" {
  type        = string
  description = "The subnet to be integrated into."
}

variable "dns_zone_name" {
  type        = string
  description = "DNS zone name for key vaults."
}

variable "dns_zone_id" {
  type        = string
  description = "The id of the given dns zone."
}