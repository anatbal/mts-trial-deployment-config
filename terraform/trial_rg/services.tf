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

  settings = {
    "WEBSITES_PORT"               = "8080" # The container is listening on 8080
  }

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

  # todo use private endpoint
  settings = {
    "SPRING_APPLICATION_NAME"     = "practitioner-service"
    "SPRING_PROFILES_ACTIVE"      = var.spring_profile
    "SPRING_CLOUD_CONFIG_LABEL"   = var.spring_config_label
    "SPRING_CLOUD_CONFIG_URI"     = "https://${module.trial_sc_config.name}.azurewebsites.net"
    "WEBSITES_PORT"               = "8080" # The container is listening on 8080
  }

  depends_on = [
    azurerm_app_service_plan.apps_service_plan,
    module.trial_sc_config,
  ]
}

# Role service
module "trial_app_service_role" {
  source              = "./modules/genericservice"
  app_name            = "role"
  rg_name             = azurerm_resource_group.trial_rg.name
  app_service_plan_id = azurerm_app_service_plan.apps_service_plan.id
  trial_name          = var.trial_name
  environment         = var.environment
  docker_image        = var.role_image_name
  docker_image_tag    = var.role_image_tag

  settings = {
    "always_on"   = "true"
    "JDBC_DRIVER" = "com.microsoft.sqlserver.jdbc.SQLServerDriver"
    # TODO: replace with KeyVault reference
    "JDBC_URL"    = "jdbc:sqlserver://${module.roles_sql_server.sqlserver_name}.database.windows.net:1433;databaseName=ROLES;user=${module.roles_sql_server.db_user};password=${module.roles_sql_server.db_password}"
    "WEBSITES_PORT"               = "8080" # The container is listening on 8080
  }

  depends_on = [
    azurerm_app_service_plan.apps_service_plan,
    module.roles_sql_server,
  ]
}

# init service
# todo: make 1-time service: ARTS-362
module "trial_app_service_init" {
  source              = "./modules/genericservice"
  app_name            = "init"
  rg_name             = azurerm_resource_group.trial_rg.name
  app_service_plan_id = azurerm_app_service_plan.apps_service_plan.id
  trial_name          = var.trial_name
  environment         = var.environment
  docker_image        = var.init_service_image_name
  docker_image_tag    = var.init_service_image_tag

  settings = {
    "always_on"   = "true"
    "WEBSITES_PORT"               = "8080" # The container is listening on 8080
  }

  depends_on = [
    azurerm_app_service_plan.apps_service_plan,
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
  docker_image        = var.sc_gateway_image_name
  docker_image_tag    = var.sc_gateway_image_tag

  settings = {
    "SERVER_PORT"                                = 8080
    "WEBSITES_PORT"                              = 8080
  }

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
  docker_image        = var.sc_discovery_image_name
  docker_image_tag    = var.sc_discovery_image_tag

  settings = {
    "SERVER_PORT"                                = 8080
    "WEBSITES_PORT"                              = 8080
  }

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
  docker_image        = var.sc_config_image_name
  docker_image_tag    = var.sc_config_image_tag

  settings = {
    "SPRING_CLOUD_CONFIG_SERVER_GIT_URI"         = var.sc_config_git_uri
    "SPRING_CLOUD_CONFIG_SERVER_GIT_SEARCHPATHS" = var.sc_config_search_paths
    "SERVER_PORT"                                = 8080
    "WEBSITES_PORT"                              = 8080
  }

  depends_on = [
    azurerm_app_service_plan.apps_service_plan,
  ]
}

## End - Spring cloud application
