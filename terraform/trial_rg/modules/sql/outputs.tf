output "sqlserver_name" {
  value       = azurerm_mssql_server.sql_server.name
  description = "The generated sql server name."
}