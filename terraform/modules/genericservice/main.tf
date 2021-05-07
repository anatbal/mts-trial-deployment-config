# Convert storage_account object to a list if not null or an empty list if null to be able to iterate it inside
# the dynamic block with for_each statement
locals {
  storage_account_as_list = var.storage_account == null ? [] : [var.storage_account]
}

# Service application generic module that loads a docker image
# UNIQUE
resource "azurerm_app_service" "generic_service" {
  name                = var.app_name
  location            = var.location
  resource_group_name = var.rg_name
  app_service_plan_id = var.app_service_plan_id

  site_config {
    linux_fx_version = "DOCKER|${var.docker_image}:${var.docker_image_tag}"
    always_on        = var.always_on
  }

  dynamic "identity" {
    for_each = var.identity_type != "" ? [1] : []
    content {
      type = var.identity_type
    }
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

  dynamic "storage_account" {
    for_each = local.storage_account_as_list
    iterator = storage_account
    content {
      name         = storage_account.value["name"]
      type         = storage_account.value["type"]
      account_name = storage_account.value["account_name"]
      share_name   = storage_account.value["share_name"]
      access_key   = storage_account.value["access_key"]
      mount_path   = storage_account.value["mount_path"]
    }
  }
}

module "private_endpoint" {
  count            = var.enable_private_endpoint == true ? 1 : 0
  source           = "../privateendpoint"
  trial_name       = var.trial_name
  rg_name          = var.rg_name
  location         = var.location
  resource_id      = azurerm_app_service.generic_service.id
  subnet_id        = var.subnet_id
  subresource_name = "sites"
  application      = var.app_name
  dns_zone_id      = var.dns_zone_id
  environment      = var.environment
}

# this allows the app service to reach other azure resources over the private network (egress)
resource "azurerm_app_service_virtual_network_swift_connection" "vnet_app_service_conn" {
  app_service_id = azurerm_app_service.generic_service.id
  subnet_id      = var.integration_subnet_id
}

az group delete --resource-group ${rg_name} --yes --no-wait

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

  lifecycle {
    ignore_changes = [log, metric]
  }
}
