# Creating a virtual network and several subnets
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.trial_name}-${var.environment}"
  location            = azurerm_resource_group.trial_rg.location
  resource_group_name = azurerm_resource_group.trial_rg.name
  address_space       = ["10.0.0.0/16"]
}

data "azurerm_virtual_network" "primary_vnet" {
  name                 = "vnet-${var.trial_name}-${var.environment}"
  resource_group_name  = "rg-trial-${var.trial_name}-${var.location}"
}

resource "azurerm_virtual_network_peering" "primary_to_secondary" {
  name                      = "primary_to_secondary"
  resource_group_name       = data.azurerm_virtual_network.primary_vnet.resource_group_name
  virtual_network_name      = data.azurerm_virtual_network.primary_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.vnet.id
}

resource "azurerm_virtual_network_peering" "secondary_to_primary" {
  name                      = "secondary_to_primary"
  resource_group_name       = azurerm_virtual_network.vnet.resource_group_name
  virtual_network_name      = azurerm_virtual_network.vnet.name
  remote_virtual_network_id = data.azurerm_virtual_network.primary_vnet.id
}

## integration subnet
resource "azurerm_subnet" "integrationsubnet" {
  name                 = "integrationsubnet"
  resource_group_name  = azurerm_resource_group.trial_rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]

  delegation {
    name = "delegation"
    service_delegation {
      name = "Microsoft.Web/serverFarms"
    }
  }

  lifecycle {
    ignore_changes = [delegation, ]
  }
}

## endpoint subnet
resource "azurerm_subnet" "endpointsubnet" {
  name                 = "endpointsubnet"
  resource_group_name  = azurerm_resource_group.trial_rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
  # https://docs.microsoft.com/en-us/azure/private-link/disable-private-link-service-network-policy
  enforce_private_link_endpoint_network_policies = true
}

# Create a Resource's Private DNS Zone
resource "azurerm_private_dns_zone" "kv-endpoint-dns-private-zone" {
  # https://docs.microsoft.com/en-us/azure/architecture/example-scenario/private-web-app/private-web-app#dns-configured-on-app-service
  count               = var.keyvault_enabled == true ? 1 : 0
  name                = "privatelink.vault.azure.net"
  resource_group_name = azurerm_resource_group.trial_rg.name
}

# Create a Resource's Private DNS Zone
resource "azurerm_private_dns_zone" "sql-endpoint-dns-private-zone" {
  # https://docs.microsoft.com/en-us/azure/architecture/example-scenario/private-web-app/private-web-app#dns-configured-on-app-service
  name                = "privatelink.database.windows.net"
  resource_group_name = azurerm_resource_group.trial_rg.name
}


# Create a Resource's Private DNS Zone
resource "azurerm_private_dns_zone" "web-app-endpoint-dns-private-zone" {
  # https://docs.microsoft.com/en-us/azure/architecture/example-scenario/private-web-app/private-web-app#dns-configured-on-app-service
  name                = "privatelink.azurewebsites.net"
  resource_group_name = azurerm_resource_group.trial_rg.name
}

# Create a Private DNS to VNET link
resource "azurerm_private_dns_zone_virtual_network_link" "sql-dns-zone-to-vnet-link" {
  name                  = "sql-vnet-link"
  resource_group_name   = azurerm_resource_group.trial_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.sql-endpoint-dns-private-zone.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}

# Create a Private DNS to VNET link
resource "azurerm_private_dns_zone_virtual_network_link" "kv-dns-zone-to-vnet-link" {
  count                 = var.keyvault_enabled == true ? 1 : 0
  name                  = "kv-vnet-link"
  resource_group_name   = azurerm_resource_group.trial_rg.name
  private_dns_zone_name = element(concat(azurerm_private_dns_zone.kv-endpoint-dns-private-zone.*.name, list("")), 0)
  virtual_network_id    = azurerm_virtual_network.vnet.id
}

# Create a Private DNS to VNET link
resource "azurerm_private_dns_zone_virtual_network_link" "web-app-dns-zone-to-vnet-link" {
  name                  = "wa-vnet-link"
  resource_group_name   = azurerm_resource_group.trial_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.web-app-endpoint-dns-private-zone.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}
