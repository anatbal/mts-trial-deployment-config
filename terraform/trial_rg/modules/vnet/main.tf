# Creating a virtual network and several subnets
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.trial_name}-${var.environment}"
  location            = var.location
  resource_group_name = var.rg_name
  address_space       = ["10.0.0.0/16"]
}

# First subnet, for the web apps
resource "azurerm_subnet" "web_apps_subnet" {
  name                 = "subnet-wa-${var.trial_name}-${var.environment}"
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

# Second subnet, for the sql servers
resource "azurerm_subnet" "sql_subnet" {
  name                 = "subnet-sql-${var.trial_name}-${var.environment}"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]

  # must for private link
  enforce_private_link_endpoint_network_policies = true
}

# Third subnet, for the KVs
resource "azurerm_subnet" "kv_subnet" {
  name                 = "subnet-kv-${var.trial_name}-${var.environment}"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.3.0/24"]

  # must for private link
  enforce_private_link_endpoint_network_policies = true
}

# Create a Private DNS Zone
resource "azurerm_private_dns_zone" "main_private_dns" {
  name                = "oxford.trials"
  resource_group_name = var.rg_name
}

# Link the Main Private DNS Zone with the VNET
resource "azurerm_private_dns_zone_virtual_network_link" "private-dns-link" {
  name                  = "vnet-link-${var.trial_name}-${var.environment}"
  resource_group_name   = var.rg_name
  private_dns_zone_name = azurerm_private_dns_zone.main_private_dns.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}
