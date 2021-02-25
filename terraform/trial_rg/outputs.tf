output "ui_conn_string" {
  value       = azurerm_storage_account.uistorageaccount.primary_connection_string
  description = "The UI storage account connection string."
  sensitive   = true
}

output "gateway_host" {
  value       = module.trial_sc_gateway.hostname
  description = "The hostname of the API gateway."
  sensitive   = false
}
