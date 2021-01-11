resource "random_password" "fhir_sql_password" {
  length = 16
  special = true
  override_special = "_%@"
}

# Deploy a sql server and db for fhir before we create the web app
module "fhir_sql_server" {
  source     = "../sql"
  trial_name = var.trial_name
  rg_name    = var.rg_name
  vnet_id    = var.vnet_id
  subnet_id  = var.subnet_id
  db_name    = "FHIR"
  app_name   = "fhir"
  sql_user   = var.fhir_sqluser
  sql_pass   = random_password.fhir_sql_password.result
  application = "sql-fhir"
}

# Fhir server
resource "azurerm_app_service" "fhir_server" {
  name                = "as-${var.trial_name}-fhir-${var.environment}"
  location            = var.location
  resource_group_name = var.rg_name
  app_service_plan_id = var.app_service_plan_id

  site_config {
    linux_fx_version = "DOCKER|${var.fhir_image_name}:${var.fhir_image_tag}"
  }

  app_settings = {
    always_on                                         = "true"
    FHIRServer__Security__Enabled                     = "false"
    SqlServer__ConnectionString                       = "Server=tcp:${module.fhir_sql_server.sqlserver_name}.database.windows.net,1433;Initial Catalog=FHIR;Persist Security Info=False;User ID=${var.fhir_sqluser};Password=${random_password.fhir_sql_password.result};MultipleActiveResultSets=False;Connection Timeout=30;"
    SqlServer__AllowDatabaseCreation                  = "true"
    SqlServer__Initialize                             = "true"
    SqlServer__SchemaOptions__AutomaticUpdatesEnabled = "true"
    DataStore                                         = "SqlServer"
    WEBSITES_PORT                                     = 8080
  }

  depends_on = [
    module.fhir_sql_server,
  ]
}