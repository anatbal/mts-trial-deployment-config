variable "rg_name" {
  type        = string
  description = "Resource group"
}

variable "trial_name" {
  type        = string
  description = "Trial name. Use only lowercase letters and numbers"
}

variable "environment" {
  type        = string
  description = "Environment name, e.g. 'dev' or 'stage'"
}

variable "resource_id" {
  type        = string
  description = "The resource id that is connected to the private link."
}

variable "subnet_id" {
  type        = string
  description = "The subnet id."
}

variable "subresource_name" {
  type = string
  # https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-overview#private-link-resource
  description = "The subresource to protect (kv/sql/webapp)"
}

variable "application" {
  type        = string
  description = "The application this endpoints relates to (workload)."
}

variable "dns_zone_id" {
  type        = string
  description = "The id of the given dns zone."
}

variable "location" {
  type = string
}