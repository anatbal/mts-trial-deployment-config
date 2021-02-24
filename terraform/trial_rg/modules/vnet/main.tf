# Creating a virtual network and several subnets
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.trial_name}-${var.environment}"
  location            = var.location
  resource_group_name = var.rg_name
  address_space       = ["10.0.0.0/16"]
}

## integration subnet
resource "azurerm_subnet" "integrationsubnet" {
  name                 = "integrationsubnet"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]

  delegation {
    name = "delegation"
    service_delegation {
      name = "Microsoft.Web/serverFarms"
    }
  }
}

## endpoint subnet
resource "azurerm_subnet" "endpointsubnet" {
  name                                           = "endpointsubnet"
  resource_group_name                            = var.rg_name
  virtual_network_name                           = azurerm_virtual_network.vnet.name
  address_prefixes                               = ["10.0.2.0/24"]
  enforce_private_link_endpoint_network_policies = true
}