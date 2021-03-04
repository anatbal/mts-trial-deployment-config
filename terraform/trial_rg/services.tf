## Service application

locals {
  site_name         = "as-${var.trial_name}-site-${var.environment}"
  practitioner_name = "as-${var.trial_name}-practitioner-${var.environment}"
  role_name         = "as-${var.trial_name}-role-${var.environment}"
  init_name         = "as-${var.trial_name}-init-${var.environment}"
  gateway_name      = "as-${var.trial_name}-sc-gateway-${var.environment}"
  discovery_name    = "as-${var.trial_name}-sc-discovery-${var.environment}"
  config_name       = "as-${var.trial_name}-sc-config-${var.environment}"
  common_settings = {
    "SERVER_PORT"                           = 80
    "WEBSITES_PORT"                         = 80
    "SPRING_PROFILES_ACTIVE"                = var.spring_profile
    "SPRING_CLOUD_CONFIG_LABEL"             = var.spring_config_label
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.app_insights.connection_string
    "EUREKA_CLIENT_SERVICEURL_DEFAULTZONE"  = "${module.trial_sc_discovery.hostname}/eureka/"
    # TODO: try to move back to a managed identity
    "INIT_SERVICE_IDENTITY"    = "e6fd67af-ef25-4a4b-af7c-0ed8a7bd40cf" # module.trial_app_service_init.identity
  }
}

# Site service
module "trial_app_service_site" {
  source              = "./modules/genericservice"
  app_name            = local.site_name
  rg_name             = azurerm_resource_group.trial_rg.name
  app_service_plan_id = azurerm_app_service_plan.apps_service_plan.id
  trial_name          = var.trial_name
  environment         = var.environment
  docker_image        = var.site_image_name
  docker_image_tag    = var.site_image_tag

  settings = merge(
    local.common_settings,
    {
      "EUREKA_INSTANCE_HOSTNAME" = "${local.site_name}.azurewebsites.net"
      "FHIR_URI"                 = module.fhir_server.hostname
    },
  )

  depends_on = [
    azurerm_app_service_plan.apps_service_plan,
    azurerm_application_insights.app_insights,
    module.trial_sc_config,
    module.trial_sc_discovery,
    module.fhir_server,
    module.trial_app_service_init,
  ]
}

# Practitioner service
module "trial_app_service_practitioner" {
  source              = "./modules/genericservice"
  app_name            = local.practitioner_name
  rg_name             = azurerm_resource_group.trial_rg.name
  app_service_plan_id = azurerm_app_service_plan.apps_service_plan.id
  trial_name          = var.trial_name
  environment         = var.environment
  docker_image        = var.practitioner_image_name
  docker_image_tag    = var.practitioner_image_tag

  # todo use private endpoint
  settings = merge(
    local.common_settings,
    {
      "EUREKA_INSTANCE_HOSTNAME" = "${local.practitioner_name}.azurewebsites.net"
      "FHIR_URI"                 = module.fhir_server.hostname
      "ROLE_SERVICE_URI"         = module.trial_app_service_role.hostname
      "SITE_SERVICE_URI"         = module.trial_app_service_site.hostname
    },
  )

  depends_on = [
    azurerm_app_service_plan.apps_service_plan,
    azurerm_application_insights.app_insights,
    module.trial_sc_config,
    module.trial_sc_discovery,
    module.trial_app_service_site,
    module.trial_app_service_role,
    module.fhir_server,
    module.trial_app_service_init,
  ]
}

# Role service
module "trial_app_service_role" {
  source              = "./modules/genericservice"
  app_name            = local.role_name
  rg_name             = azurerm_resource_group.trial_rg.name
  app_service_plan_id = azurerm_app_service_plan.apps_service_plan.id
  trial_name          = var.trial_name
  environment         = var.environment
  docker_image        = var.role_image_name
  docker_image_tag    = var.role_image_tag

  settings = merge(
    local.common_settings,
    {
      "EUREKA_INSTANCE_HOSTNAME" = "${local.role_name}.azurewebsites.net"
      # TODO: this setting should be fetched from the config server
      "JDBC_DRIVER"           = "com.microsoft.sqlserver.jdbc.SQLServerDriver"
      # TODO: replace with KeyVault reference
      "JDBC_URL"                 = "jdbc:sqlserver://${module.roles_sql_server.sqlserver_name}.database.windows.net:1433;databaseName=ROLES;user=${module.roles_sql_server.db_user};password=${module.roles_sql_server.db_password}"
    },
  )

  depends_on = [
    azurerm_app_service_plan.apps_service_plan,
    azurerm_application_insights.app_insights,
    module.roles_sql_server,
    module.trial_sc_config,
    module.trial_sc_discovery,
    module.trial_app_service_init,
  ]
}

# init service
# todo: make 1-time service: ARTS-362
module "trial_app_service_init" {
  source              = "./modules/genericservice"
  app_name            = local.init_name
  rg_name             = azurerm_resource_group.trial_rg.name
  app_service_plan_id = azurerm_app_service_plan.apps_service_plan.id
  trial_name          = var.trial_name
  environment         = var.environment
  docker_image        = var.init_service_image_name
  docker_image_tag    = var.init_service_image_tag

  settings = merge(
    local.common_settings,
    {
      "SPRING_MAIN_WEB_APPLICATION_TYPE" = "" # brings up the spring web app despite being a console app
      "AZURE_USERNAME"                   = var.init_username
      "AZURE_PASSWORD"                   = var.init_password
      "AZURE_CLIENT_ID"                  = var.init_client_id
    },
  )

  depends_on = [
    azurerm_app_service_plan.apps_service_plan,
    azurerm_application_insights.app_insights,
    module.trial_sc_config,
    module.trial_sc_discovery,
  ]
}

## End - Service application

## Spring cloud application

# config server service
module "trial_sc_gateway" {
  source              = "./modules/genericservice"
  app_name            = local.gateway_name
  rg_name             = azurerm_resource_group.trial_rg.name
  app_service_plan_id = azurerm_app_service_plan.apps_service_plan.id
  trial_name          = var.trial_name
  environment         = var.environment
  docker_image        = var.sc_gateway_image_name
  docker_image_tag    = var.sc_gateway_image_tag

  settings = merge(
    local.common_settings,
    {
      "EUREKA_INSTANCE_HOSTNAME" = "${local.gateway_name}.azurewebsites.net"
    },
  )

  depends_on = [
    azurerm_app_service_plan.apps_service_plan,
    azurerm_application_insights.app_insights,
    module.trial_sc_config,
    module.trial_sc_discovery,
  ]
}

module "trial_sc_discovery" {
  source              = "./modules/genericservice"
  app_name            = local.discovery_name
  rg_name             = azurerm_resource_group.trial_rg.name
  app_service_plan_id = azurerm_app_service_plan.apps_service_plan.id
  trial_name          = var.trial_name
  environment         = var.environment
  docker_image        = var.sc_discovery_image_name
  docker_image_tag    = var.sc_discovery_image_tag

  settings = {
    "SPRING_PROFILES_ACTIVE"                = var.spring_profile
    "SERVER_PORT"                           = 80
    "WEBSITES_PORT"                         = 80
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.app_insights.connection_string
    "EUREKA_ENVIRONMENT" = var.environment # for a label in the eureka status screen
  }

  depends_on = [
    azurerm_app_service_plan.apps_service_plan,
    azurerm_application_insights.app_insights,
  ]
}

module "trial_sc_config" {
  source              = "./modules/genericservice"
  app_name            = local.config_name
  rg_name             = azurerm_resource_group.trial_rg.name
  app_service_plan_id = azurerm_app_service_plan.apps_service_plan.id
  trial_name          = var.trial_name
  environment         = var.environment
  docker_image        = var.sc_config_image_name
  docker_image_tag    = var.sc_config_image_tag

  # optted not to use the common settings since it includes a config label that might casue problems here.
  settings = {
    "EUREKA_INSTANCE_HOSTNAME"                   = "${local.config_name}.azurewebsites.net"
    "SPRING_PROFILES_ACTIVE"                     = var.spring_profile
    "SPRING_CLOUD_CONFIG_SERVER_GIT_URI"         = var.sc_config_git_uri
    "SPRING_CLOUD_CONFIG_SERVER_GIT_SEARCHPATHS" = var.sc_config_search_paths
    "SERVER_PORT"                                = 80
    "WEBSITES_PORT"                              = 80
    "EUREKA_CLIENT_SERVICEURL_DEFAULTZONE"       = "${module.trial_sc_discovery.hostname}/eureka/"
    "APPLICATIONINSIGHTS_CONNECTION_STRING"      = azurerm_application_insights.app_insights.connection_string
  }

  depends_on = [
    azurerm_app_service_plan.apps_service_plan,
    azurerm_application_insights.app_insights,
    module.trial_sc_discovery,
  ]
}

## End - Spring cloud application
