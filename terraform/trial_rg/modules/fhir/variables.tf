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

variable "app_service_plan_id" {
  type        = string
  description = "The app service plan id."
}

variable "fhir_image_name" {
  type        = string
  description = "Fhir image name (fqdn)."
  default     = "mcr.microsoft.com/healthcareapis/r4-fhir-server"
}

variable "fhir_image_tag" {
  type        = string
  description = "Fhir image tag."
  default     = "latest"
}

variable "fhir_sqluser" {
  type        = string
  description = "Fhir sql server user."
  default     = "myfhiruser"
}

variable "endpointsubnet" {
  type        = string
  description = "The subnet id."
}

variable "vnet_id" {
  type        = string
  description = "The vnet id."
}