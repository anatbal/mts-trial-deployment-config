locals {
  api_backend_pool_name     = "fd-${var.trial_name}-apipool-${var.environment}"
  api_backend_balancer_name = "fd-${var.trial_name}-apibalancer-${var.environment}"
  api_frontend_endpoint     = "fd-${var.trial_name}-apiendpoint-${var.environment}"
  api_backend_health_probe  = "fd-${var.trial_name}-apihealth-${var.environment}"
  ui_backend_pool_name      = "fd-${var.trial_name}-uipool-${var.environment}"
  ui_backend_balancer_name  = "fd-${var.trial_name}-uibalancer-${var.environment}"
  frontend_endpoint         = "fd-${var.trial_name}-endpoint-${var.environment}"
  ui_backend_health_probe   = "fd-${var.trial_name}-uihealth-${var.environment}"
  storage_account_name      = "sa${var.trial_name}ui${local.failover_env}"
}

resource "azurerm_frontdoor" "frontdoor" {
  count                                        = var.is_failover_deployment ? 0 : 1
  name                                         = "fd-${var.trial_name}-${var.environment}"
  resource_group_name                          = azurerm_resource_group.trial_rg.name
  enforce_backend_pools_certificate_name_check = true

  routing_rule {
    name               = "fd-${var.trial_name}-uirouting-${var.environment}"
    accepted_protocols = ["Https"]
    patterns_to_match  = ["/*"]
    frontend_endpoints = [local.frontend_endpoint]
    forwarding_configuration {
      forwarding_protocol = "MatchRequest"
      backend_pool_name   = local.ui_backend_pool_name
    }
  }

  routing_rule {
    name               = "fd-${var.trial_name}-apirouting-${var.environment}"
    accepted_protocols = ["Https"]
    patterns_to_match  = ["/api/*"]
    frontend_endpoints = [local.frontend_endpoint]
    forwarding_configuration {
      forwarding_protocol = "MatchRequest"
      backend_pool_name   = local.api_backend_pool_name
    }
  }

  ## UI routing
  backend_pool_load_balancing {
    name = local.ui_backend_balancer_name
  }

  backend_pool_health_probe {
    name = local.ui_backend_health_probe
  }

  backend_pool {
    name = "fd-${var.trial_name}-uipool-${var.environment}"
    backend {
      host_header = azurerm_storage_account.uistorageaccount.primary_web_host
      address     = azurerm_storage_account.uistorageaccount.primary_web_host
      http_port   = 80
      https_port  = 443
    }
    load_balancing_name = local.ui_backend_balancer_name
    health_probe_name   = local.ui_backend_health_probe
  }

  ## API routing
  backend_pool_load_balancing {
    name = local.api_backend_balancer_name
  }

  backend_pool_health_probe {
    name = local.api_backend_health_probe
  }

  backend_pool {
    name = "fd-${var.trial_name}-apipool-${var.environment}"
    backend {
      host_header = "as-${var.trial_name}-sc-gateway-primary.azurewebsites.net"
      address     = "as-${var.trial_name}-sc-gateway-primary.azurewebsites.net"
      http_port   = 80
      https_port  = 443
      priority    = 1
    }

    backend {
      host_header = "as-${var.trial_name}-sc-gateway-secondary.azurewebsites.net"
      address     = "as-${var.trial_name}-sc-gateway-secondary.azurewebsites.net"
      http_port   = 80
      https_port  = 443
      priority    = 2
    }

    load_balancing_name = local.api_backend_balancer_name
    health_probe_name   = local.api_backend_health_probe
  }


  frontend_endpoint {
    name      = local.frontend_endpoint
    host_name = "fd-${var.trial_name}-${var.environment}.azurefd.net"
  }
}
