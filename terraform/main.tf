# Trial RG
module "trial_rg" {
  source                  = "./trial_rg"
  trial_name              = var.trial_name
  environment             = var.environment
  site_image_name         = var.site_image_name
  site_image_tag          = var.site_image_tag
  practitioner_image_name = var.practitioner_image_name
  practitioner_image_tag  = var.practitioner_image_tag
  # Initialisation?
  trial_config_service_image_name = var.trial_config_service_image_name
  trial_config_service_image_tag  = var.trial_config_service_image_tag
}