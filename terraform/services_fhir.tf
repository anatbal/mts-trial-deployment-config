module "fhir_server" {
  source               = "./modules/genericservice"
  app_name             = "as-${var.trial_name}-fhir-${local.failover_env}"
  rg_name              = azurerm_resource_group.trial_rg.name
  location             = azurerm_resource_group.trial_rg.location
  app_service_plan_id  = azurerm_app_service_plan.apps_service_plan.id
  trial_name           = var.trial_name
  environment          = var.environment
  docker_image         = "mcr.microsoft.com/healthcareapis/r4-fhir-server"
  docker_image_tag     = "latest"
  monitor_workspace_id = azurerm_log_analytics_workspace.monitor_workspace.id

  enable_private_endpoint = var.enable_private_endpoint
  subnet_id               = azurerm_subnet.endpointsubnet.id
  dns_zone_id             = azurerm_private_dns_zone.web-app-endpoint-dns-private-zone.id
  integration_subnet_id   = azurerm_subnet.integrationsubnet.id

  settings = {
    FHIRServer__Security__Enabled = "false"
    # TODO: replace with KeyVault reference
    SqlServer__ConnectionString                       = "Server=tcp:${module.fhir_sql.failover_name}.database.windows.net,1433;Initial Catalog=FHIR;Persist Security Info=False;User ID=${module.fhir_sql.db_user};Password=${module.fhir_sql.db_password};MultipleActiveResultSets=False;Connection Timeout=30;"
    SqlServer__AllowDatabaseCreation                  = "true"
    SqlServer__Initialize                             = "true"
    SqlServer__SchemaOptions__AutomaticUpdatesEnabled = "true"
    DataStore                                         = "SqlServer"
    WEBSITES_PORT                                     = 8080
    WEBSITE_DNS_SERVER                                = "168.63.129.16"
    WEBSITE_VNET_ROUTE_ALL                            = 1
    ApplicationInsights__InstrumentationKey           = azurerm_application_insights.app_insights.instrumentation_key
  }

  depends_on = [
    # make sure the app isn't created before everything in the sql module is ready
    module.fhir_sql,
  ]
}

resource "random_password" "fhir_sql_password" {
  length           = 16
  special          = true
  override_special = "_%@"
  min_upper        = 1
  min_lower        = 1
  min_numeric      = 1
}

module "fhir_sql" {
  source                  = "./modules/sql"
  trial_name              = var.trial_name
  rg_name                 = azurerm_resource_group.trial_rg.name
  location                = azurerm_resource_group.trial_rg.location
  primary_location        = var.location
  failover_name           = "failover-fhir-dr3"
  db_name                 = "FHIR"
  app_name                = "fhir"
  sql_user                = "fhiruser"
  sql_pass                = random_password.fhir_sql_password.result
  application             = "sql-fhir"
  environment             = var.environment
  monitor_workspace_id    = azurerm_log_analytics_workspace.monitor_workspace.id
  is_failover_deployment  = var.is_failover_deployment
  enable_private_endpoint = var.enable_private_endpoint
  subnet_id               = azurerm_subnet.endpointsubnet.id
  dns_zone_id             = azurerm_private_dns_zone.sql-endpoint-dns-private-zone.id
}
