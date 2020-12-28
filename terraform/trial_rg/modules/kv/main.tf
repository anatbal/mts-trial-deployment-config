
resource "azurerm_key_vault" "trial_keyvault" {
  name                        = "trial-${var.trial_name}-kv"
  location                    = var.location
  resource_group_name         = var.rg_name
  enabled_for_disk_encryption = true
  tenant_id                   = var.tenant_id

  sku_name = "standard"
}