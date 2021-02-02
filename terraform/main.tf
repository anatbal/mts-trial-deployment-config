# Trial RG
module "trial_rg" {
  source                  = "./trial_rg"
  trial_name              = var.trial_name
  environment             = var.environment
  site_image_name         = var.site_image_name
  site_image_tag          = var.site_image_tag
  practitioner_image_name = var.practitioner_image_name
  practitioner_image_tag  = var.practitioner_image_tag

  init_service_image_name = var.init_service_image_name
  init_service_image_tag  = var.init_service_image_tag

  # Spring cloud
  sc_gateway_image_name = var.sc_gateway_image_name
  sc_gateway_image_tag  = var.sc_gateway_image_tag

  sc_discovery_image_name = var.sc_discovery_image_name
  sc_discovery_image_tag  = var.sc_discovery_image_tag

  sc_config_image_name   = var.sc_config_image_name
  sc_config_image_tag    = var.sc_config_image_tag
  sc_config_git_uri      = var.sc_config_git_uri
  sc_config_search_paths = var.sc_config_search_paths
}