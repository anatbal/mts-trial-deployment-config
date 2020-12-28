variable "rg_name" {
  type        = string
  description = "The Resource group where this appservice will be deployed"
}

variable "plan_id" {
  type        = string
  description = "service plan id to be connected to this appservice"
}

variable "tenant_id" {
  type        = string
  description = "The Tenant id"
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
}

variable "environment" {
  type        = string
  description = "Environment name, e.g. 'dev' or 'stage'"
  default     = "dev"
}

variable "location" {
  type        = string
  description = "Azure region where to create resources."
  default     = "UK south"
}