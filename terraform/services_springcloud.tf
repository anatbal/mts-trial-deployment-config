## Spring cloud application

locals {
  discovery_name = "as-${var.trial_name}-sc-discovery-${local.failover_env}"
  config_name    = "as-${var.trial_name}-sc-config-${local.failover_env}"
  gateway_name   = "as-${var.trial_name}-sc-gateway-${local.failover_env}"
  common_springcloud_settings = {
    "SERVER_PORT"                           = 80
    "WEBSITES_PORT"                         = 80
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.app_insights.connection_string
    "EUREKA_CLIENT_SERVICEURL_DEFAULTZONE"  = "${module.trial_sc_discovery.hostname}/eureka/"
    "SPRING_PROFILES_ACTIVE"                = var.spring_profile
    "WEBSITE_DNS_SERVER"                    = "168.63.129.16"
    "WEBSITE_VNET_ROUTE_ALL"                = 1
  }
}

module "trial_sc_discovery" {
  source               = "./modules/genericservice"
  app_name             = local.discovery_name
  rg_name              = azurerm_resource_group.trial_rg.name
  location             = azurerm_resource_group.trial_rg.location
  app_service_plan_id  = azurerm_app_service_plan.apps_service_plan.id
  trial_name           = var.trial_name
  environment          = var.environment
  docker_image         = var.sc_discovery_image_name
  docker_image_tag     = var.sc_discovery_image_tag
  monitor_workspace_id = azurerm_log_analytics_workspace.monitor_workspace.id

  enable_private_endpoint = var.enable_private_endpoint
  subnet_id               = azurerm_subnet.endpointsubnet.id
  dns_zone_id             = azurerm_private_dns_zone.web-app-endpoint-dns-private-zone.id
  integration_subnet_id   = azurerm_subnet.integrationsubnet.id

  settings = {
    "SPRING_PROFILES_ACTIVE"                = var.spring_profile
    "SERVER_PORT"                           = 80
    "WEBSITES_PORT"                         = 80
    "WEBSITE_DNS_SERVER"                    = "168.63.129.16"
    "WEBSITE_VNET_ROUTE_ALL"                = 1
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.app_insights.connection_string
    "EUREKA_ENVIRONMENT"                    = var.environment # for a label in the eureka status screen
  }
}

module "trial_sc_config" {
  source               = "./modules/genericservice"
  app_name             = local.config_name
  rg_name              = azurerm_resource_group.trial_rg.name
  location             = azurerm_resource_group.trial_rg.location
  app_service_plan_id  = azurerm_app_service_plan.apps_service_plan.id
  trial_name           = var.trial_name
  environment          = var.environment
  docker_image         = var.sc_config_image_name
  docker_image_tag     = var.sc_config_image_tag
  monitor_workspace_id = azurerm_log_analytics_workspace.monitor_workspace.id

  enable_private_endpoint = var.enable_private_endpoint
  subnet_id               = azurerm_subnet.endpointsubnet.id
  dns_zone_id             = azurerm_private_dns_zone.web-app-endpoint-dns-private-zone.id
  integration_subnet_id   = azurerm_subnet.integrationsubnet.id

  settings = merge(
    local.common_springcloud_settings,
    {
      "EUREKA_INSTANCE_HOSTNAME"                   = "${local.config_name}.azurewebsites.net"
      "SPRING_CLOUD_CONFIG_SERVER_GIT_URI"         = var.sc_config_git_uri
      "SPRING_CLOUD_CONFIG_SERVER_GIT_SEARCHPATHS" = var.sc_config_search_paths
    },
  )

  depends_on = [
    module.trial_sc_discovery,
  ]
}

module "trial_sc_gateway" {
  source               = "./modules/genericservice"
  app_name             = local.gateway_name
  rg_name              = azurerm_resource_group.trial_rg.name
  location             = azurerm_resource_group.trial_rg.location
  app_service_plan_id  = azurerm_app_service_plan.apps_service_plan.id
  trial_name           = var.trial_name
  environment          = var.environment
  docker_image         = var.sc_gateway_image_name
  docker_image_tag     = var.sc_gateway_image_tag
  monitor_workspace_id = azurerm_log_analytics_workspace.monitor_workspace.id

  enable_private_endpoint = false
  # These variables are not used due to the fact we don't create a private endpoint
  # for the gateway, but are required by tf
  subnet_id             = azurerm_subnet.endpointsubnet.id
  dns_zone_id           = azurerm_private_dns_zone.web-app-endpoint-dns-private-zone.id
  integration_subnet_id = azurerm_subnet.integrationsubnet.id

  settings = merge(
    local.common_springcloud_settings,
    {
      "EUREKA_INSTANCE_HOSTNAME"  = "${local.gateway_name}.azurewebsites.net"
      "SPRING_CLOUD_CONFIG_LABEL" = var.spring_config_label
    },
  )

  depends_on = [
    module.trial_sc_config,
    module.trial_sc_discovery,
  ]
}

## End - Spring cloud application
