output "service_id" {
  value       = azurerm_app_service.fhir_server.id
  description = "The fhir app service id."
}