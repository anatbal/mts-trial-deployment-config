output "ui_conn_string" {
  value       = azurerm_storage_account.uistorageaccount.primary_connection_string
  description = "The UI storage account connection string."
  sensitive   = true
}
