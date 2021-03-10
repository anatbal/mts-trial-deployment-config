variable "rg_name" {
  type        = string
  description = "The Resource group where this appservice will be deployed"

  validation {
    # https://github.com/toddkitta/azure-content/blob/master/articles/guidance/guidance-naming-conventions.md
    condition     = length(var.rg_name) > 3 && length(var.rg_name) < 64 && can(regex("[a-z,0-9,-,_]", var.rg_name))
    error_message = "The rg_name must consist of lowercase letters, numbers underscores, and hyphens only."
  }
}

variable "app_service_plan_id" {
  type        = string
  description = "service plan id to be connected to this appservice"
}

variable "trial_name" {
  type        = string
  description = "Trial name. Use only lowercase letters and numbers"
}

variable "app_name" {
  type        = string
  description = "Application name. Use only lowercase letters and numbers"
}

variable "docker_image" {
  type        = string
  description = "Docker image"
}

variable "docker_image_tag" {
  type        = string
  description = "Docker image tag"
  default     = "latest"
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

variable "settings" {
  type      = map(any)
  default   = {}
  sensitive = true
}

variable "subnet_id" {
  type        = string
  description = "The subnet id of the web app."
}

variable "dns_zone_id" {
  type        = string
  description = "The id of the given dns zone."
}

variable "enable_private_endpoint" {
  type        = bool
  description = "if 'false' then for this web app, private endpoint will NOT be created."
  default     = true
}