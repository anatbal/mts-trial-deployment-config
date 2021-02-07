variable "trial_name" {
  type        = string
  description = "Application name. Use only lowercase letters and numbers"
  default     = "starterterraform"
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

variable "site_image_name" {
  type        = string
  description = "site image name (fqdn)."
}

variable "site_image_tag" {
  type        = string
  description = "site image tag."
  default     = "latest"
}

variable "practitioner_image_name" {
  type        = string
  description = "practitioner image name (fqdn)."
}

variable "practitioner_image_tag" {
  type        = string
  description = "practitioner image tag."
  default     = "latest"
}

variable "init_service_image_name" {
  type        = string
  description = "trial configuration service image name (fqdn)."
}

variable "init_service_image_tag" {
  type        = string
  description = "trial configuration service image tag."
  default     = "latest"
}

variable "sc_gateway_image_name" {
  type        = string
  description = "SC gateway image name."
}

variable "sc_gateway_image_tag" {
  type        = string
  description = "SC gateway image tag."
  default     = "latest"
}

variable "sc_discovery_image_name" {
  type        = string
  description = "SC discovery image name."
}

variable "sc_discovery_image_tag" {
  type        = string
  description = "SC discovery image tag."
  default     = "latest"
}

variable "sc_config_image_name" {
  type        = string
  description = "SC config image name."
}

variable "sc_config_image_tag" {
  type        = string
  description = "SC config image tag."
  default     = "latest"
}

variable "sc_config_git_uri" {
  type        = string
  description = "Git configuration uri, from which to pull all the applications configuration"
}

variable "sc_config_search_paths" {
  type        = string
  description = "Search path within the git uri, to find different configs for the different apps."
}

variable "spring_profile" {
  type        = string
  description = "Spring cloud profile (dev, prod, etc)."
}

variable "spring_config_label" {
  type        = string
  description = "Spring cloud label (branch)."
}