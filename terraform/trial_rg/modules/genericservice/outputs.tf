output "service_id" {
  value       = azurerm_app_service.generic_service.id
  description = "The id of the generated app service."
}