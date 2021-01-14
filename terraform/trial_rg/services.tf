## Service application

# Site service
module "trial_app_service_site" {
  source              = "./modules/genericservice"
  app_name            = "site"
  rg_name             = azurerm_resource_group.trial_rg.name
  app_service_plan_id = azurerm_app_service_plan.apps_service_plan.id
  trial_name          = var.trial_name
  environment         = var.environment
  docker_image        = var.site_image_name
  docker_image_tag    = var.site_image_tag

  depends_on = [
    azurerm_app_service_plan.apps_service_plan,
  ]
}

# Practitioner service
module "trial_app_service_practitioner" {
  source              = "./modules/genericservice"
  app_name            = "practitioner"
  rg_name             = azurerm_resource_group.trial_rg.name
  app_service_plan_id = azurerm_app_service_plan.apps_service_plan.id
  trial_name          = var.trial_name
  environment         = var.environment
  docker_image        = var.practitioner_image_name
  docker_image_tag    = var.practitioner_image_tag

  depends_on = [
    azurerm_app_service_plan.apps_service_plan,
  ]
}

# config server service
module "trial_app_service_config" {
  source              = "./modules/genericservice"
  app_name            = "config"
  rg_name             = azurerm_resource_group.trial_rg.name
  app_service_plan_id = azurerm_app_service_plan.apps_service_plan.id
  trial_name          = var.trial_name
  environment         = var.environment
  docker_image        = var.trial_config_service_image_name
  docker_image_tag    = var.trial_config_service_image_tag

  settings = {
    "always_on"   = "true",
    "JDBC_DRIVER" = "com.microsoft.sqlserver.jdbc.SQLServerDriver",
    "JDBC_URL"    = "jdbc:sqlserver://${module.roles_sql_server.sqlserver_name}.database.windows.net:1433;databaseName=ROLES;user=${module.roles_sql_server.db_user};password=${module.roles_sql_server.db_password}"
  }

  depends_on = [
    azurerm_app_service_plan.apps_service_plan,
    module.roles_sql_server,
  ]
}

## End - Service application

## Spring cloud application

# config server service
module "trial_sc_gateway" {
  source              = "./modules/genericservice"
  app_name            = "sc-gateway"
  rg_name             = azurerm_resource_group.trial_rg.name
  app_service_plan_id = azurerm_app_service_plan.apps_service_plan.id
  trial_name          = var.trial_name
  environment         = var.environment
  docker_image        = var.trial_sc_gateway_image_name
  docker_image_tag    = var.trial_sc_gateway_image_tag

  depends_on = [
    azurerm_app_service_plan.apps_service_plan,
  ]
}

module "trial_sc_discovery" {
  source              = "./modules/genericservice"
  app_name            = "sc-discovery"
  rg_name             = azurerm_resource_group.trial_rg.name
  app_service_plan_id = azurerm_app_service_plan.apps_service_plan.id
  trial_name          = var.trial_name
  environment         = var.environment
  docker_image        = var.trial_sc_discovery_image_name
  docker_image_tag    = var.trial_sc_discovery_image_tag

  depends_on = [
    azurerm_app_service_plan.apps_service_plan,
  ]
}

module "trial_sc_config" {
  source              = "./modules/genericservice"
  app_name            = "sc-config"
  rg_name             = azurerm_resource_group.trial_rg.name
  app_service_plan_id = azurerm_app_service_plan.apps_service_plan.id
  trial_name          = var.trial_name
  environment         = var.environment
  docker_image        = var.trial_sc_config_image_name
  docker_image_tag    = var.trial_sc_config_image_tag

  depends_on = [
    azurerm_app_service_plan.apps_service_plan,
  ]
}

## End - Spring cloud application
