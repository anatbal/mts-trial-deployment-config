output "private_endpoint_ip" {
  value       = azurerm_private_endpoint.private_endpoint.private_service_connection[0].private_ip_address
  description = "The private endpoint private ip address."
}
