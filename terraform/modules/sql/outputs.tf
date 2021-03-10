output "sqlserver_name" {
  value       = azurerm_mssql_server.sql_server.name
  description = "The generated sql server name."
}

output "db_user" {
  value       = azurerm_mssql_server.sql_server.administrator_login
  description = "The password for logging in to the database."
  sensitive   = true
}

output "db_password" {
  value       = azurerm_mssql_server.sql_server.administrator_login_password
  description = "The password for logging in to the database."
  sensitive   = true
}
