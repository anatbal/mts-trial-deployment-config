resource "azurerm_postgresql_server" "postgres_server" {
  name                = "${var.trial_name}-postgresql-server"
  location            = var.location
  resource_group_name = var.rg_name

  sku_name = "B_Gen5_2"

  storage_mb                   = 5120
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = true

  # administrator_login          = "psqladminun"
  # administrator_login_password = ""
  version                      = "9.5"
  ssl_enforcement_enabled      = true
}

resource "azurerm_postgresql_database" "postgres_database" {
  name                = "${var.trial_name}-postgresql-db"
  resource_group_name = var.rg_name
  server_name         = azurerm_postgresql_server.postgres_server.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}