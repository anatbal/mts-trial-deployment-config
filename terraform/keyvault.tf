
data "azurerm_client_config" "current" {}

# TODO: HAS TO BE UNIQUE. https://ndph-arts.atlassian.net/browse/ARTS-367
resource "azurerm_key_vault" "trial_keyvault" {
  count                       = var.keyvault_enabled == true ? 1 : 0
  name                        = "kv-${var.trial_name}-${var.environment}"
  location                    = var.is_failover_deployment ? var.failover_location : azurerm_resource_group.trial_rg.location
  resource_group_name         = azurerm_resource_group.trial_rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id

  sku_name = "standard"

  # define ACLs so that the KV will be in the vnet
  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }
}

# Connect KV to a new private endpoint
module "private_endpoint" {
  count      = var.keyvault_enabled && var.enable_private_endpoint == true ? 1 : 0
  source     = "./modules/privateendpoint"
  trial_name = var.trial_name
  rg_name    = azurerm_resource_group.trial_rg.name
  location   = var.is_failover_deployment ? var.failover_location : var.location
  # the following expression is a workaround since the keyvault might not exist and TF doesn't know to handle that.
  resource_id      = element(concat(azurerm_key_vault.trial_keyvault.*.id, list("")), 0)
  subnet_id        = azurerm_subnet.endpointsubnet.id
  subresource_name = "vault"
  application      = "kv"
  dns_zone_id      = element(concat(azurerm_private_dns_zone.kv-endpoint-dns-private-zone.*.id, list("")), 0)
  environment      = var.environment
}
