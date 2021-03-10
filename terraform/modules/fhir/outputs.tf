output "service_id" {
  value       = azurerm_app_service.fhir_server.id
  description = "The fhir app service id."
}

output "hostname" {
  value       = "https://${azurerm_app_service.fhir_server.default_site_hostname}"
  description = "The default hostname of the web app."
}