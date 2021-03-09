output "integrationsubnet" {
  value       = azurerm_subnet.integrationsubnet.id
  description = "The generated integration id."
}

output "endpointsubnet" {
  value       = azurerm_subnet.endpointsubnet.id
  description = "The generated endpointsubnet id."
}

output "id" {
  value       = azurerm_virtual_network.vnet.id
  description = "The generated vnet id."
}

output "sql_dns_zone_name" {
  value       = azurerm_private_dns_zone.sql-endpoint-dns-private-zone.name
  description = "DNS zone name for sql servers"
}

output "sql_dns_zone_id" {
  value       = azurerm_private_dns_zone.sql-endpoint-dns-private-zone.id
  description = "The id of the given dns zone."
}

output "kv_dns_zone_name" {
  value       = azurerm_private_dns_zone.kv-endpoint-dns-private-zone.name
  description = "DNS zone name for key vaults."
}

output "kv_dns_zone_id" {
  value       = azurerm_private_dns_zone.kv-endpoint-dns-private-zone.id
  description = "The id of the given dns zone."
}

output "webapp_dns_zone_name" {
  value       = azurerm_private_dns_zone.web-app-endpoint-dns-private-zone.name
  description = "DNS zone name for web applications."
}

output "webapp_dns_zone_id" {
  value       = azurerm_private_dns_zone.web-app-endpoint-dns-private-zone.id
  description = "The id of the given dns zone."
}
