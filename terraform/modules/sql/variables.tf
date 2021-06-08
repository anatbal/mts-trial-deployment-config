variable "rg_name" {
  type        = string
  description = "Resource group"
}

variable "trial_name" {
  type        = string
  description = "Trial name. Use only lowercase letters and numbers"
}

variable "primary_location" {
  type        = string
  description = "Primary location"
}

variable "failover_name" {
  type        = string
  description = "Failover name"
}

variable "is_failover_deployment" {
  type        = bool
  description = "Is failover deployment"
}

variable "environment" {
  type        = string
  description = "Environment name, e.g. 'dev' or 'stage'"
}

variable "subnet_id" {
  type        = string
  description = "The subnet id."
}

variable "db_name" {
  type        = string
  description = "The db name."
}

variable "app_name" {
  type        = string
  description = "The name of the app to use the sql server."
}

variable "sql_user" {
  type        = string
  description = "The SQL user."
}

variable "sql_pass" {
  type        = string
  description = "The SQL pass."
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

variable "monitor_workspace_id" {
  type        = string
  description = "A LogAnalytics workspace id"
}

variable "enable_private_endpoint" {
  type        = bool
  description = "if 'false' then for this web app, private endpoint will NOT be created."
}
