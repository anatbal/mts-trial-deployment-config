
# SQL server
resource "azurerm_mssql_server" "sql_server" {
  name                          = "sql-server-${var.trial_name}-${var.app_name}-${var.environment}"
  location                      = var.location
  resource_group_name           = var.rg_name
  version                       = "12.0"
  administrator_login           = var.sql_user
  administrator_login_password  = var.sql_pass
  public_network_access_enabled = true # TODO: set to false when private link works

}

# DB
resource "azurerm_mssql_database" "sqldb" {
  name                        = var.db_name
  server_id                   = azurerm_mssql_server.sql_server.id
  sku_name                    = "GP_S_Gen5_2" # serverless
  max_size_gb                 = 4
  auto_pause_delay_in_minutes = -1
  min_capacity                = 1
  # max_capacity = 2

  depends_on = [
    azurerm_mssql_server.sql_server,
  ]
}

# TODO: currect this and uncomment

# After the SQL server is deployed, connect it to a new private endpoint
# module "private_endpoint" {
#   source        = "../privateendpoint"
#   trial_name    = var.trial_name
#   rg_name       = var.rg_name
#   resource_name = azurerm_mssql_server.sql_server.name
#   resource_id   = azurerm_mssql_server.sql_server.id
#   vnet_id       = var.vnet_id
#   subnet_id     = var.subnet_id
#   sql           = true
#   application   = var.application
# }


# TODO: delete this when private endpoints work.
# Allow access for azure services
resource "azurerm_sql_firewall_rule" "example" {
  name                = "FirewallRule1"
  resource_group_name = azurerm_mssql_server.sql_server.resource_group_name
  server_name         = azurerm_mssql_server.sql_server.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}