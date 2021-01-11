variable "rg_name" {
  type        = string
  description = "Resource group"

  validation {
    # https://github.com/toddkitta/azure-content/blob/master/articles/guidance/guidance-naming-conventions.md
    condition     = length(var.rg_name) > 3 && length(var.rg_name) < 64 && can(regex("[a-z,0-9,-,_]", var.rg_name))
    error_message = "The rg_name must consist of lowercase letters, numbers underscores, and hyphens only."
  }
}

variable "trial_name" {
  type        = string
  description = "Trial name. Use only lowercase letters and numbers"
}

variable "location" {
  type        = string
  description = "Azure region where to create resources."
  default     = "uksouth"
}

variable "environment" {
  type        = string
  description = "Environment name, e.g. 'dev' or 'stage'"
  default     = "dev"
}

variable "resource_name" {
  type        = string
  description = "The resource name that is connected to the private link."
}

variable "resource_id" {
  type        = string
  description = "The resource id that is connected to the private link."
}

variable "vnet-cidr" {
  type        = string
  description = "The CIDR of the VNET"
  default     = "10.0.0.0/16"
}

variable "db-subnet-cidr" {
  type        = string
  description = "The CIDR for the Backoffice subnet"
  default     = "10.0.1.0/24"
}

variable "subnet_id" {
  type        = string
  description = "The subnet id."
}

variable "vnet_id" {
  type        = string
  description = "The vnet id."
}

variable "kv" {
  type        = bool
  description = "is related to kv."
  default     = false
}

variable "sql" {
  type        = bool
  description = "is related to sql."
  default     = false
}

variable "application" {
  type        = string
  description = "The application this endpoints relates to (workload)."
}