output "private_link_endpoint_ip" {
  description = "Private Link Endpoint IP"
  value = data.azurerm_private_endpoint_connection.endpoint-connection.private_service_connection.0.private_ip_address
}