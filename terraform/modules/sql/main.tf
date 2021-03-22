
# SQL server
resource "azurerm_mssql_server" "sql_server" {
  name                         = "sql-server-${var.trial_name}-${var.app_name}-${var.environment}"
  location                     = var.location
  resource_group_name          = var.rg_name
  version                      = "12.0"
  administrator_login          = var.sql_user
  administrator_login_password = var.sql_pass
  # Block external communication
  public_network_access_enabled = false
}

# DB
resource "azurerm_mssql_database" "sqldb" {
  name        = var.db_name
  server_id   = azurerm_mssql_server.sql_server.id
  sku_name    = "S0" # a small sku, probably not right for production
  max_size_gb = 2
}

# After the SQL server is deployed, connect it to a new private endpoint
module "private_endpoint" {
  source           = "../privateendpoint"
  trial_name       = var.trial_name
  rg_name          = var.rg_name
  resource_id      = azurerm_mssql_server.sql_server.id
  subnet_id        = var.subnet_id
  subresource_name = "sqlServer"
  application      = var.application
  dns_zone_id      = var.dns_zone_id
}