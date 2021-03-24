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
    "INIT_SERVICE_IDENTITY"  = "e6fd67af-ef25-4a4b-af7c-0ed8a7bd40cf" # module.trial_app_service_init.identity
    "WEBSITE_DNS_SERVER"     = "168.63.129.16"
    "WEBSITE_VNET_ROUTE_ALL" = 1
  }
}

# Site service
module "trial_app_service_site" {
  source               = "./modules/genericservice"
  app_name             = local.site_name
  rg_name              = azurerm_resource_group.trial_rg.name
  app_service_plan_id  = azurerm_app_service_plan.apps_service_plan.id
  trial_name           = var.trial_name
  environment          = var.environment
  docker_image         = var.site_image_name
  docker_image_tag     = var.site_image_tag
  subnet_id            = azurerm_subnet.endpointsubnet.id
  dns_zone_id          = azurerm_private_dns_zone.web-app-endpoint-dns-private-zone.id
  monitor_workspace_id = azurerm_log_analytics_workspace.monitor_workspace.id

  settings = merge(
    local.common_settings,
    {
      "EUREKA_INSTANCE_HOSTNAME" = "${local.site_name}.azurewebsites.net"
      "FHIR_URI"                 = module.fhir_server.hostname
    },
  )

  depends_on = [
    module.trial_sc_config,
    module.trial_sc_discovery,
  ]
}

# Practitioner service
module "trial_app_service_practitioner" {
  source               = "./modules/genericservice"
  app_name             = local.practitioner_name
  rg_name              = azurerm_resource_group.trial_rg.name
  app_service_plan_id  = azurerm_app_service_plan.apps_service_plan.id
  trial_name           = var.trial_name
  environment          = var.environment
  docker_image         = var.practitioner_image_name
  docker_image_tag     = var.practitioner_image_tag
  subnet_id            = azurerm_subnet.endpointsubnet.id
  dns_zone_id          = azurerm_private_dns_zone.web-app-endpoint-dns-private-zone.id
  monitor_workspace_id = azurerm_log_analytics_workspace.monitor_workspace.id

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
    module.trial_sc_config,
    module.trial_sc_discovery,
  ]
}

# Role service
module "trial_app_service_role" {
  source               = "./modules/genericservice"
  app_name             = local.role_name
  rg_name              = azurerm_resource_group.trial_rg.name
  app_service_plan_id  = azurerm_app_service_plan.apps_service_plan.id
  trial_name           = var.trial_name
  environment          = var.environment
  docker_image         = var.role_image_name
  docker_image_tag     = var.role_image_tag
  subnet_id            = azurerm_subnet.endpointsubnet.id
  dns_zone_id          = azurerm_private_dns_zone.web-app-endpoint-dns-private-zone.id
  monitor_workspace_id = azurerm_log_analytics_workspace.monitor_workspace.id

  settings = merge(
    local.common_settings,
    {
      "EUREKA_INSTANCE_HOSTNAME" = "${local.role_name}.azurewebsites.net"
      # TODO: this setting should be fetched from the config server
      "JDBC_DRIVER" = "com.microsoft.sqlserver.jdbc.SQLServerDriver"
      # TODO: replace with KeyVault reference
      "JDBC_URL" = "jdbc:sqlserver://${module.roles_sql_server.sqlserver_name}.database.windows.net:1433;databaseName=ROLES;user=${module.roles_sql_server.db_user};password=${module.roles_sql_server.db_password}"
    },
  )

  depends_on = [
    module.trial_sc_config,
    module.trial_sc_discovery,
  ]
}

resource "azurerm_storage_account" "initstorageaccount" {
  name                      = "sa${var.trial_name}init${var.environment}"
  resource_group_name       = azurerm_resource_group.trial_rg.name
  location                  = azurerm_resource_group.trial_rg.location
  account_kind              = "StorageV2"
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  enable_https_traffic_only = true
  allow_blob_public_access  = true
}

resource "azurerm_storage_share" "initstorageshare" {
  name                 = "init"
  storage_account_name = azurerm_storage_account.initstorageaccount.name
  quota                = 1
}

# init service
module "trial_app_service_init" {
  source               = "./modules/genericservice"
  app_name             = local.init_name
  rg_name              = azurerm_resource_group.trial_rg.name
  app_service_plan_id  = azurerm_app_service_plan.apps_service_plan.id
  trial_name           = var.trial_name
  environment          = var.environment
  docker_image         = var.init_service_image_name
  docker_image_tag     = var.init_service_image_tag
  subnet_id            = azurerm_subnet.endpointsubnet.id
  dns_zone_id          = azurerm_private_dns_zone.web-app-endpoint-dns-private-zone.id
  monitor_workspace_id = azurerm_log_analytics_workspace.monitor_workspace.id
  storage_account = ({
    "name"         = azurerm_storage_account.initstorageaccount.name
    "type"         = "AzureFiles"
    "account_name" = azurerm_storage_account.initstorageaccount.name
    "share_name"   = azurerm_storage_share.initstorageshare.name
    "access_key"   = azurerm_storage_account.initstorageaccount.primary_access_key
    "mount_path"   = var.init_log_path
  })

  settings = merge(
    local.common_settings,
    {
      "SPRING_MAIN_WEB_APPLICATION_TYPE" = "" # brings up the spring web app despite being a console app
      "AZURE_USERNAME"                   = var.init_username
      "AZURE_PASSWORD"                   = var.init_password
      "AZURE_CLIENT_ID"                  = var.init_client_id
      "PROGRESS_LOG_PATH"                = "${var.init_log_path}/log.txt"
    },
  )

  depends_on = [
    azurerm_app_service_plan.apps_service_plan,
    azurerm_application_insights.app_insights,
    azurerm_storage_account.initstorageaccount,
    azurerm_storage_share.initstorageshare,
    module.trial_sc_config,
    module.trial_sc_discovery,
  ]
}

## End - Service application

## Spring cloud application

# config server service
module "trial_sc_gateway" {
  source                  = "./modules/genericservice"
  app_name                = local.gateway_name
  rg_name                 = azurerm_resource_group.trial_rg.name
  app_service_plan_id     = azurerm_app_service_plan.apps_service_plan.id
  trial_name              = var.trial_name
  environment             = var.environment
  docker_image            = var.sc_gateway_image_name
  docker_image_tag        = var.sc_gateway_image_tag
  enable_private_endpoint = false
  monitor_workspace_id    = azurerm_log_analytics_workspace.monitor_workspace.id

  # These variables are not used due to the fact we don't create a private endpoint
  # for the gateway, but are required by tf
  subnet_id   = azurerm_subnet.endpointsubnet.id
  dns_zone_id = azurerm_private_dns_zone.web-app-endpoint-dns-private-zone.id

  settings = merge(
    local.common_settings,
    {
      "EUREKA_INSTANCE_HOSTNAME" = "${local.gateway_name}.azurewebsites.net"
    },
  )

  depends_on = [
    module.trial_sc_config,
    module.trial_sc_discovery,
  ]
}

module "trial_sc_discovery" {
  source               = "./modules/genericservice"
  app_name             = local.discovery_name
  rg_name              = azurerm_resource_group.trial_rg.name
  app_service_plan_id  = azurerm_app_service_plan.apps_service_plan.id
  trial_name           = var.trial_name
  environment          = var.environment
  docker_image         = var.sc_discovery_image_name
  docker_image_tag     = var.sc_discovery_image_tag
  subnet_id            = azurerm_subnet.endpointsubnet.id
  dns_zone_id          = azurerm_private_dns_zone.web-app-endpoint-dns-private-zone.id
  monitor_workspace_id = azurerm_log_analytics_workspace.monitor_workspace.id

  settings = {
    "SPRING_PROFILES_ACTIVE"                = var.spring_profile
    "SERVER_PORT"                           = 80
    "WEBSITES_PORT"                         = 80
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.app_insights.connection_string
    "EUREKA_ENVIRONMENT"                    = var.environment # for a label in the eureka status screen
  }
}

module "trial_sc_config" {
  source               = "./modules/genericservice"
  app_name             = local.config_name
  rg_name              = azurerm_resource_group.trial_rg.name
  app_service_plan_id  = azurerm_app_service_plan.apps_service_plan.id
  trial_name           = var.trial_name
  environment          = var.environment
  docker_image         = var.sc_config_image_name
  docker_image_tag     = var.sc_config_image_tag
  subnet_id            = azurerm_subnet.endpointsubnet.id
  dns_zone_id          = azurerm_private_dns_zone.web-app-endpoint-dns-private-zone.id
  monitor_workspace_id = azurerm_log_analytics_workspace.monitor_workspace.id

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
    "WEBSITE_DNS_SERVER"                         = "168.63.129.16"
    "WEBSITE_VNET_ROUTE_ALL"                     = 1
  }
}

## End - Spring cloud application
