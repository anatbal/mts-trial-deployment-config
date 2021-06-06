output "server_fqdn" {
  value       = azurerm_mssql_server.sql_server_primary.fully_qualified_domain_name
  description = "The fully qualified domain name of the server."
}

output "db_user" {
  value       = azurerm_mssql_server.sql_server_primary.administrator_login
  description = "The admin username for the server."
}

output "db_password" {
  value       = azurerm_mssql_server.sql_server_primary.administrator_login_password
  description = "The admin password for the server."
  sensitive   = true
}
