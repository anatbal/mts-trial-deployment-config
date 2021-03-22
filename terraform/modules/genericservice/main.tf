
# Service application generic module that loads a docker image
# UNIQUE
resource "azurerm_app_service" "generic_service" {
  name                = var.app_name
  location            = var.location
  resource_group_name = var.rg_name
  app_service_plan_id = var.app_service_plan_id

  site_config {
    linux_fx_version = "DOCKER|${var.docker_image}:${var.docker_image_tag}"
    always_on        = true
  }

  identity {
    type = "SystemAssigned"
  }

  logs {
    http_logs {
      file_system {
        retention_in_mb   = 30 # in Megabytes
        retention_in_days = 30 # in days
      }
    }

    detailed_error_messages_enabled = true
    failed_request_tracing_enabled  = true
  }

  app_settings = var.settings
}

# count = 0, if this is the gateway and no private endpoint is needed
module "private_endpoint" {
  count            = var.enable_private_endpoint == true ? 1 : 0
  source           = "../privateendpoint"
  trial_name       = var.trial_name
  rg_name          = var.rg_name
  resource_id      = azurerm_app_service.generic_service.id
  subnet_id        = var.subnet_id
  subresource_name = "sites"
  application      = var.app_name
  dns_zone_id      = var.dns_zone_id
}

resource "azurerm_monitor_diagnostic_setting" "app_diag" {
  name                       = "${var.app_name}-diagnostic"
  target_resource_id         = azurerm_app_service.generic_service.id
  log_analytics_workspace_id = var.monitor_workspace_id

  log {
    category = "AppServiceConsoleLogs"
    enabled  = false # Logs are sent to AppInsights which is better than this
  }
  log {
    category = "AppServiceHTTPLogs"
    enabled  = true
  }
  log {
    category = "AppServiceAuditLogs"
    enabled  = true
  }
  log {
    category = "AppServiceFileAuditLogs"
    enabled  = true
  }
  log {
    category = "AppServiceAppLogs"
    enabled  = true
  }
  log {
    category = "AppServiceIPSecAuditLogs"
    enabled  = true
  }
  log {
    category = "AppServicePlatformLogs"
    enabled  = true
  }

  metric {
    category = "AllMetrics"
  }
}