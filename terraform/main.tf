# Trial RG
module "trial_rg" {
  source      = "./trial_rg"
  trial_name  = var.trial_name
  environment = var.environment
}