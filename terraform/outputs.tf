output "ui_conn_string" {
  value       = module.trial_rg.ui_conn_string
  description = "The UI storage account connection string."
  sensitive   = true
}