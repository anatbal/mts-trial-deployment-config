# Trial Resource Group

resource "azurerm_resource_group" "trial_rg" {
  name     = "rg-trial-${var.trial_name}-${var.environment}"
  location = var.location
  tags = {
    Owner = "user@contoso.com"
  }
}

## Service plan
resource "azurerm_app_service_plan" "apps_service_plan" {
  name                = "trial-${var.trial_name}-genericserviceplan"
  location            = azurerm_resource_group.trial_rg.location
  resource_group_name = azurerm_resource_group.trial_rg.name
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Standard"
    size = "S1"
  }
}

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
}

# Key vault
module "trial_keyvault" {
  source      = "./modules/kv"
  trial_name  = var.trial_name
  environment = var.environment
  rg_name     = azurerm_resource_group.trial_rg.name
  tenant_id   = "99804659-431f-48fa-84c1-65c9609de05b"
}

# Audit storage
module "trial_audit" {
  source     = "./modules/audit"
  trial_name = var.trial_name
  rg_name    = azurerm_resource_group.trial_rg.name
}

# Fhir server
module "fhir_server" {
  source              = "./modules/fhir"
  trial_name          = var.trial_name
  rg_name             = azurerm_resource_group.trial_rg.name
  app_service_plan_id = azurerm_app_service_plan.apps_service_plan.id
}


# config server service
module "trial_app_service_config" {
  source              = "./modules/genericservice"
  app_name            = "config"
  rg_name             = azurerm_resource_group.trial_rg.name
  app_service_plan_id = azurerm_app_service_plan.apps_service_plan.id
  trial_name          = var.trial_name
  environment         = var.environment
  docker_image        = var.trial_config_service_image_name
  docker_image_tag    = var.trial_config_service_image_tag
}
