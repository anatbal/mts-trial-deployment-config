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
  default     = "UK south"
}