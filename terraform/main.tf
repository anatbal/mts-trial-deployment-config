# Trial Resource Group
resource "azurerm_resource_group" "trial_rg" {
  name     = "rg-trial-${var.trial_name}"
  location = var.location
  tags = {
    Owner       = var.owner
    Environment = var.environment
    Ref         = var.github_ref
  }
}

## Service plan
resource "azurerm_app_service_plan" "apps_service_plan" {
  name                = "asp-${var.trial_name}-${var.environment}"
  location            = azurerm_resource_group.trial_rg.location
  resource_group_name = azurerm_resource_group.trial_rg.name
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "PremiumV2"
    size = "P1v2"
  }
}

# Application insights
resource "azurerm_application_insights" "app_insights" {
  name                = "ai-${var.trial_name}-${var.environment}"
  location            = azurerm_resource_group.trial_rg.location
  resource_group_name = azurerm_resource_group.trial_rg.name
  application_type    = "web"
}

resource "azurerm_log_analytics_workspace" "monitor_workspace" {
  name                = "amw-${var.trial_name}-${var.environment}"
  location            = azurerm_resource_group.trial_rg.location
  resource_group_name = azurerm_resource_group.trial_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# Storage account for UI elemenet
# TODO: HAS TO BE UNIQUE. https://ndph-arts.atlassian.net/browse/ARTS-367
resource "azurerm_storage_account" "uistorageaccount" {
  name                      = "sa${var.trial_name}ui${var.environment}"
  resource_group_name       = azurerm_resource_group.trial_rg.name
  location                  = azurerm_resource_group.trial_rg.location
  account_kind              = "StorageV2"
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  enable_https_traffic_only = true
  allow_blob_public_access  = true
  min_tls_version           = "TLS1_2"

  static_website {
    index_document = "index.html"
  }
}
