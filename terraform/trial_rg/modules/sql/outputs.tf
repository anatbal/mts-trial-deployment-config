output "sqlserver_name" {
  value       = azurerm_mssql_server.sql_server.name
  description = "The generated sql server name."
}

# TODO: currect this and uncomment

# output "private_link_endpoint_ip" {
#   description = "Private Link Endpoint IP"
#   value = module.private_endpoint.private_link_endpoint_ip
# }

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
