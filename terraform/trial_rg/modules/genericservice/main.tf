
# Service application generic module that loads a docker image

resource "azurerm_app_service" "generic_service" {
  name                = "trial-${var.trial_name}-app-service-${var.app_name}"
  location            = var.location
  resource_group_name = var.rg_name
  app_service_plan_id = var.app_service_plan_id

  site_config {
    linux_fx_version = "DOCKER|${var.docker_image}:${var.docker_image_tag}"
  }

  app_settings = {
    always_on = "true"
  }
}