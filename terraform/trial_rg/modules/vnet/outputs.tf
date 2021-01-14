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