# Shared Resource Group

# Here and everywhere else. naming conventions:
# https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming
resource "azurerm_resource_group" "shared_rg" {
  name     = "rg-shared-${var.environment}"
  location = var.location
  tags = {
    Owner = "user@contoso.com"
  }
}

# ---- Azure Monitor ----
# Storage account
resource "azurerm_storage_account" "shared_sa_appinsights" {
  name                     = "saaioxford${var.environment}"
  resource_group_name      = azurerm_resource_group.shared_rg.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_application_insights" "shared_monitor_ai" {
  name                = "ai-oxford-${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.shared_rg.name
  application_type    = "web"
}

resource "azurerm_log_analytics_workspace" "shared_monitor_analytics" {
  name                = "la-oxford-${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.shared_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# ---- END Azure Monitor ----