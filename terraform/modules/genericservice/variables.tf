variable "rg_name" {
  type        = string
  description = "The Resource group where this appservice will be deployed"
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
}

variable "storage_account" {
  type = object({
    name         = string
    type         = string
    account_name = string
    share_name   = string
    access_key   = string
    mount_path   = string
  })
  sensitive   = true
  description = "(Optional) a list of Storage Accounts blob or file share to mount"
  default     = null
}

variable "monitor_workspace_id" {
  type        = string
  description = "A LogAnalytics workspace id"
}

variable "integration_subnet_id" {
  type = string
}

variable "health_check_path" {
  type = string
}

variable "identity_type" {
  type    = string
  default = ""
}

variable "location" {
  type = string
}

variable "always_on" {
  type    = bool
  default = true
}
