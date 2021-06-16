resource "random_string" "random" {
  length  = 4
  lower   = true
  number  = true
  upper   = false
  special = false
}

resource "azurerm_mssql_server" "sql_server" {
  name                         = "sql-server-${var.trial_name}-${var.app_name}-${var.environment}-${var.location}"
  location                     = var.location
  resource_group_name          = var.rg_name
  version                      = "12.0"
  administrator_login          = var.sql_user
  administrator_login_password = var.sql_pass

  # If private endpoints are enabled, block external communication
  public_network_access_enabled = var.enable_private_endpoint ? false : true
}

# If private endpoints are enabled, no need to open access for "azure services"
resource "azurerm_mssql_firewall_rule" "sql_firewall_rule" {
  count            = var.enable_private_endpoint ? 0 : 1
  name             = "AzureServicesRule"
  server_id        = azurerm_mssql_server.sql_server.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# DB
resource "azurerm_mssql_database" "sqldb" {
  count       = var.is_failover_deployment ? 0 : 1
  name        = var.db_name
  server_id   = azurerm_mssql_server.sql_server.id
  sku_name    = "S0" # a small sku, probably not right for production
  max_size_gb = 2
}

# After the SQL server is deployed, connect it to a new private endpoint
module "private_endpoint" {
  count            = var.enable_private_endpoint ? 1 : 0
  source           = "../privateendpoint"
  trial_name       = var.trial_name
  rg_name          = var.rg_name
  location         = var.location
  resource_id      = azurerm_mssql_server.sql_server.id
  subnet_id        = var.subnet_id
  subresource_name = "sqlServer"
  application      = var.application
  dns_zone_id      = var.dns_zone_id
  environment      = var.environment
}

data "azurerm_mssql_server" "primary" {
  count               = var.is_failover_deployment ? 1 : 0
  name                = "sql-server-${var.trial_name}-${var.app_name}-${var.environment}-${var.primary_location}"
  resource_group_name = "rg-trial-${var.trial_name}-${var.primary_location}"
}

data "azurerm_mssql_database" "sqldb" {
  count     = var.is_failover_deployment ? 1 : 0
  name      = var.db_name
  server_id = data.azurerm_mssql_server.primary[0].id
}


resource "azurerm_private_dns_a_record" "sql_server_dns_record" {
  count               = var.is_failover_deployment ? 1 : 0
  name                = azurerm_mssql_server.sql_server.name
  zone_name           = "privatelink.database.windows.net"
  resource_group_name = data.azurerm_mssql_server.primary[0].resource_group_name
  ttl                 = 300
  records             = [module.private_endpoint[0].private_endpoint_ip]
}

resource "azurerm_sql_failover_group" "sql_failover_group" {
  count               = var.is_failover_deployment ? 1 : 0
  name                = var.failover_name
  resource_group_name = data.azurerm_mssql_server.primary[0].resource_group_name
  server_name         = data.azurerm_mssql_server.primary[0].name
  databases           = [data.azurerm_mssql_database.sqldb[0].id]
  partner_servers {
    id = azurerm_mssql_server.sql_server.id
  }
  read_write_endpoint_failover_policy {
    mode          = "Automatic"
    grace_minutes = 60
  }
}
