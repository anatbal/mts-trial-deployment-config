## Service applications
locals {
  site_name         = "as-${var.trial_name}-site-${var.environment}"
  practitioner_name = "as-${var.trial_name}-practitioner-${var.environment}"
  role_name         = "as-${var.trial_name}-role-${var.environment}"
  init_name         = "as-${var.trial_name}-init-${var.environment}"
  common_settings = {
    "SERVER_PORT"                           = 80
    "WEBSITES_PORT"                         = 80
    "SPRING_PROFILES_ACTIVE"                = var.spring_profile
    "SPRING_CLOUD_CONFIG_LABEL"             = var.spring_config_label
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.app_insights.connection_string
    "EUREKA_CLIENT_SERVICEURL_DEFAULTZONE"  = "${module.trial_sc_discovery.hostname}/eureka/"
    "WEBSITE_DNS_SERVER"     = "168.63.129.16"
    "WEBSITE_VNET_ROUTE_ALL" = 1
  }
}

# Site service
module "trial_app_service_site" {
  source               = "./modules/genericservice"
  app_name             = local.site_name
  rg_name              = azurerm_resource_group.trial_rg.name
  location             = azurerm_resource_group.trial_rg.location
  app_service_plan_id  = azurerm_app_service_plan.apps_service_plan.id
  trial_name           = var.trial_name
  environment          = var.environment
  docker_image         = var.site_image_name
  docker_image_tag     = var.site_image_tag
  monitor_workspace_id = azurerm_log_analytics_workspace.monitor_workspace.id

  enable_private_endpoint = var.enable_private_endpoint
  subnet_id               = azurerm_subnet.endpointsubnet.id
  dns_zone_id             = azurerm_private_dns_zone.web-app-endpoint-dns-private-zone.id
  integration_subnet_id   = azurerm_subnet.integrationsubnet.id

  settings = merge(
    local.common_settings,
    {
      "EUREKA_INSTANCE_HOSTNAME" = "${local.site_name}.azurewebsites.net"
      "FHIR_URI"                 = module.fhir_server.hostname
    },
  )

  depends_on = [
    module.trial_sc_discovery,
    module.trial_sc_config,
    module.fhir_server,
  ]
}

# Practitioner service
module "trial_app_service_practitioner" {
  source               = "./modules/genericservice"
  app_name             = local.practitioner_name
  rg_name              = azurerm_resource_group.trial_rg.name
  location             = azurerm_resource_group.trial_rg.location
  app_service_plan_id  = azurerm_app_service_plan.apps_service_plan.id
  trial_name           = var.trial_name
  environment          = var.environment
  docker_image         = var.practitioner_image_name
  docker_image_tag     = var.practitioner_image_tag
  monitor_workspace_id = azurerm_log_analytics_workspace.monitor_workspace.id

  enable_private_endpoint = var.enable_private_endpoint
  subnet_id               = azurerm_subnet.endpointsubnet.id
  dns_zone_id             = azurerm_private_dns_zone.web-app-endpoint-dns-private-zone.id
  integration_subnet_id   = azurerm_subnet.integrationsubnet.id

  settings = merge(
    local.common_settings,
    {
      "EUREKA_INSTANCE_HOSTNAME" = "${local.practitioner_name}.azurewebsites.net"
      "FHIR_URI"                 = module.fhir_server.hostname
    },
  )

  depends_on = [
    module.trial_sc_discovery,
    module.trial_sc_config,
    module.fhir_server,
  ]
}

# Role service
module "trial_app_service_role" {
  source               = "./modules/genericservice"
  app_name             = local.role_name
  rg_name              = azurerm_resource_group.trial_rg.name
  location             = azurerm_resource_group.trial_rg.location
  app_service_plan_id  = azurerm_app_service_plan.apps_service_plan.id
  trial_name           = var.trial_name
  environment          = var.environment
  docker_image         = var.role_image_name
  docker_image_tag     = var.role_image_tag
  monitor_workspace_id = azurerm_log_analytics_workspace.monitor_workspace.id

  enable_private_endpoint = var.enable_private_endpoint
  subnet_id               = azurerm_subnet.endpointsubnet.id
  dns_zone_id             = azurerm_private_dns_zone.web-app-endpoint-dns-private-zone.id
  integration_subnet_id   = azurerm_subnet.integrationsubnet.id

  settings = merge(
    local.common_settings,
    {
      "EUREKA_INSTANCE_HOSTNAME" = "${local.role_name}.azurewebsites.net"
      # TODO: this setting should be fetched from the config server
      "JDBC_DRIVER" = "com.microsoft.sqlserver.jdbc.SQLServerDriver"
      # TODO: replace with KeyVault reference
      "JDBC_URL" = "jdbc:sqlserver://${module.roles_sql_server.server_fqdn}:1433;databaseName=ROLES;user=${module.roles_sql_server.db_user};password=${module.roles_sql_server.db_password}"
      # since this service does db migrations, interuptting it will render the whole env useless (due to the db "lock").
      "WEBSITES_CONTAINER_START_TIME_LIMIT" = 600 # default is 230
    },
  )

  depends_on = [
    module.trial_sc_discovery,
    module.trial_sc_config,
    module.roles_sql_server,
  ]
}

# Roles SQL
resource "random_password" "roles_sql_password" {
  length           = 16
  special          = true
  override_special = "_%@"
  min_upper        = 1
  min_lower        = 1
  min_numeric      = 1
}

module "roles_sql_server" {
  source               = "./modules/sql"
  trial_name           = var.trial_name
  location             = azurerm_resource_group.trial_rg.location
  rg_name              = azurerm_resource_group.trial_rg.name
  db_name              = "ROLES"
  app_name             = "roles"
  sql_user             = "rolesuser"
  sql_pass             = random_password.roles_sql_password.result
  application          = "sql-roles"
  environment          = var.environment
  monitor_workspace_id = azurerm_log_analytics_workspace.monitor_workspace.id

  enable_private_endpoint = var.enable_private_endpoint
  subnet_id               = azurerm_subnet.endpointsubnet.id
  dns_zone_id             = azurerm_private_dns_zone.sql-endpoint-dns-private-zone.id
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
  location             = azurerm_resource_group.trial_rg.location
  app_service_plan_id  = azurerm_app_service_plan.apps_service_plan.id
  trial_name           = var.trial_name
  environment          = var.environment
  docker_image         = var.init_service_image_name
  docker_image_tag     = var.init_service_image_tag
  monitor_workspace_id = azurerm_log_analytics_workspace.monitor_workspace.id
  identity_type        = "SystemAssigned"
  storage_account = ({
    "name"         = azurerm_storage_account.initstorageaccount.name
    "type"         = "AzureFiles"
    "account_name" = azurerm_storage_account.initstorageaccount.name
    "share_name"   = azurerm_storage_share.initstorageshare.name
    "access_key"   = azurerm_storage_account.initstorageaccount.primary_access_key
    "mount_path"   = var.init_log_path
  })

  enable_private_endpoint = var.enable_private_endpoint
  subnet_id               = azurerm_subnet.endpointsubnet.id
  dns_zone_id             = azurerm_private_dns_zone.web-app-endpoint-dns-private-zone.id
  integration_subnet_id   = azurerm_subnet.integrationsubnet.id


  settings = merge(
    local.common_settings,
    {
      "SPRING_MAIN_WEB_APPLICATION_TYPE" = "" # brings up the spring web app despite being a console app
      "PROGRESS_LOG_PATH"                = "${var.init_log_path}/log.txt"
    },
  )

  depends_on = [
    module.trial_sc_discovery,
    module.trial_sc_config,
    module.trial_app_service_role,
    module.trial_app_service_site,
    module.trial_app_service_practitioner,
    azurerm_storage_share.initstorageshare,
  ]
}

## End - Service application
