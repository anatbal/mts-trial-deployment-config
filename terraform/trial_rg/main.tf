# Trial Resource Group

resource "azurerm_resource_group" "trial_rg" {
  name     = "rg-trial-${var.trial_name}-${var.environment}"
  location = var.location
  tags = {
    Owner = "user@contoso.com"
  }
}

## service plan
resource "azurerm_app_service_plan" "apps_service_plan" {
  name                = "trial-${var.trial_name}-appserviceplan"
  location            = azurerm_resource_group.trial_rg.location
  resource_group_name = azurerm_resource_group.trial_rg.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

module "trial_app_service_site" {
  source           = "./modules/appservice"
  app_name         = "site"
  rg_name          = azurerm_resource_group.trial_rg.name
  plan_id          = azurerm_app_service_plan.apps_service_plan.id
  tenant_id        = "99804659-431f-48fa-84c1-65c9609de05b"
  trial_name       = var.trial_name
  environment      = var.environment
  docker_image     = "someimage"
  docker_image_tag = "latest"
}

module "trial_app_service_practitioner" {
  source           = "./modules/appservice"
  app_name         = "practitioner"
  rg_name          = azurerm_resource_group.trial_rg.name
  tenant_id        = "99804659-431f-48fa-84c1-65c9609de05b"
  plan_id          = azurerm_app_service_plan.apps_service_plan.id
  trial_name       = var.trial_name
  environment      = var.environment
  docker_image     = "someimage"
  docker_image_tag = "latest"
}

module "trial_keyvault" {
  source      = "./modules/kv"
  trial_name  = var.trial_name
  environment = var.environment
  rg_name     = azurerm_resource_group.trial_rg.name
  tenant_id   = "99804659-431f-48fa-84c1-65c9609de05b"
}

## add keyvault, fhir, etc