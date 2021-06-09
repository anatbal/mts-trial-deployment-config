output "ui_conn_string" {
  value       = azurerm_storage_account.uistorageaccount.primary_connection_string
  description = "The UI storage account connection string."
  sensitive   = true
}

output "gateway_host" {
  value       = "fd-${var.trial_name}-${var.environment}.azurefd.net"
  description = "The hostname of the API gateway."
  sensitive   = false
}

output "init_storage_conn_string" {
  value       = azurerm_storage_account.initstorageaccount.primary_connection_string
  description = "The init service storage account connection string."
  sensitive   = true
}

output "init_storage_share_name" {
  value       = azurerm_storage_share.initstorageshare.name
  description = "The init service storage account share name."
  sensitive   = true
}

output "init_service_identity" {
  value = module.trial_app_service_init.identity
}
