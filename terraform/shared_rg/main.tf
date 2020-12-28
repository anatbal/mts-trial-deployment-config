# Shared Resource Group

resource "azurerm_resource_group" "shared_rg" {
  name     = "rg-shared-ox-${var.environment}"
  location = var.location
  tags = {
    Owner = "user@contoso.com"
  }
}

# ---- Azure Monitor ----
# Storage account
resource "azurerm_storage_account" "shared_sa_appinsights" {
  name                     = "saappinsight"
  resource_group_name      = azurerm_resource_group.shared_rg.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_application_insights" "shared_monitor_ai" {
  name                = "shared-ox-trials-appinsights"
  location            = var.location
  resource_group_name = azurerm_resource_group.shared_rg.name
  application_type    = "web"
}

resource "azurerm_log_analytics_workspace" "shared_monitor_analytics" {
  name                = "shared-ox-trials-analytics"
  location            = var.location
  resource_group_name = azurerm_resource_group.shared_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# ---- END Azure Monitor ----