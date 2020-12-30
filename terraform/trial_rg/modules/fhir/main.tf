resource "random_password" "fhirsqlpassword" {
  length = 16
  special = true
  override_special = "_%@"
}

# backend SQL for the FHIR server
resource "azurerm_sql_server" "fhir_sql_server" {
  name                         = "${var.trial_name}fhirsqlserver"
  location                     = var.location
  resource_group_name          = var.rg_name
  version                      = "12.0"
  administrator_login          = var.fhirsqluser
  administrator_login_password = random_password.fhirsqlpassword.result
}

# We open this sql server to accept connections from other Azure resources ('Allow access to Azure services').
# Done by setting the start/end ips to 0.0.0.0.
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/sql_firewall_rule
# todo: create vnet and remove this rule
resource "azurerm_sql_firewall_rule" "firewall_rule_allow_azure_connections" {
  name                = "${var.trial_name}-srvr-allow-azure-conn"
  resource_group_name = var.rg_name
  server_name         = azurerm_sql_server.fhir_sql_server.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"

  depends_on = [
    azurerm_sql_server.fhir_sql_server,
  ]
}

# FHIR DB
resource "azurerm_sql_database" "fhirdb" {
  name                = "FHIR"
  resource_group_name = var.rg_name
  location            = var.location
  server_name         = azurerm_sql_server.fhir_sql_server.name

  depends_on = [
    azurerm_sql_server.fhir_sql_server,
  ]
}

# Fhir server
resource "azurerm_app_service" "fhir_server" {
  name                = "trial-${var.trial_name}-fhir"
  location            = var.location
  resource_group_name = var.rg_name
  app_service_plan_id = var.app_service_plan_id

  site_config {
    linux_fx_version = "DOCKER|${var.fhir_image_name}:${var.fhir_image_tag}"
  }

  app_settings = {
    always_on                                         = "true"
    FHIRServer__Security__Enabled                     = "false"
    SqlServer__ConnectionString                       = "Server=tcp:${azurerm_sql_server.fhir_sql_server.name}.database.windows.net,1433;Initial Catalog=FHIR;Persist Security Info=False;User ID=${var.fhirsqluser};Password=${random_password.fhirsqlpassword.result};MultipleActiveResultSets=False;Connection Timeout=30;"
    SqlServer__AllowDatabaseCreation                  = "true"
    SqlServer__Initialize                             = "true"
    SqlServer__SchemaOptions__AutomaticUpdatesEnabled = "true"
    DataStore                                         = "SqlServer"
    WEBSITES_PORT                                     = 8080
  }

  depends_on = [
    azurerm_sql_server.fhir_sql_server,
    azurerm_sql_database.fhirdb,
    azurerm_sql_firewall_rule.firewall_rule_allow_azure_connections
  ]
}