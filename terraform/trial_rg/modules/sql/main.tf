
# SQL server
resource "azurerm_mssql_server" "sql_server" {
  name                          = "sql-server-${var.trial_name}-${var.app_name}-${var.environment}"
  location                      = var.location
  resource_group_name           = var.rg_name
  version                       = "12.0"
  administrator_login           = var.sql_user
  administrator_login_password  = var.sql_pass
  public_network_access_enabled = false
}

# DB
resource "azurerm_sql_database" "sqldb" {
  name                = var.db_name
  resource_group_name = var.rg_name
  location            = var.location
  server_name         = azurerm_mssql_server.sql_server.name

  depends_on = [
    azurerm_mssql_server.sql_server,
  ]
}

# After the SQL server is deployed, connect it to a new private endpoint
module "private_endpoint" {
  source        = "../privateendpoint"
  trial_name    = var.trial_name
  rg_name       = var.rg_name
  resource_name = azurerm_mssql_server.sql_server.name
  resource_id   = azurerm_mssql_server.sql_server.id
  vnet_id       = var.vnet_id
  subnet_id     = var.subnet_id
  sql           = true
  application   = var.application
}