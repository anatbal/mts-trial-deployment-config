output "webapps_subnet_id" {
  value       = azurerm_subnet.web_apps_subnet.id
  description = "The generated subnet id."
}

output "sql_subnet_id" {
  value       = azurerm_subnet.sql_subnet.id
  description = "The generated subnet id."
}

output "kv_subnet_id" {
  value       = azurerm_subnet.kv_subnet.id
  description = "The generated subnet id."
}

output "id" {
  value       = azurerm_virtual_network.vnet.id
  description = "The generated vnet id."
}