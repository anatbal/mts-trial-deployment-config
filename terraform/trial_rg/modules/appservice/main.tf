
# App service (web app)

# Todo, get image name and tag
resource "azurerm_app_service" "trial_app_service" {
  name                = "trial-${var.trial_name}-app-service-${var.app_name}"
  location            = var.location
  resource_group_name = var.rg_name
  app_service_plan_id = var.plan_id

  site_config {
    dotnet_framework_version = "v4.0"
    scm_type                 = "LocalGit"
  }

  app_settings = {
    "SOME_KEY" = "some-value"
  }
}