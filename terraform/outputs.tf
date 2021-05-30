output "ui_conn_string" {
  value       = azurerm_storage_account.uistorageaccount.primary_connection_string
  description = "The UI storage account connection string."
  sensitive   = true
}

output "gateway_host" {
  value       = "https://${azurerm_frontdoor.frontdoor.frontend_endpoint[0].host_name}"
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
