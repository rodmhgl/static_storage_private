resource "azurerm_key_vault" "certificates" {
  name                          = local.akv_name
  resource_group_name           = azurerm_resource_group.this.name
  location                      = azurerm_resource_group.this.location
  sku_name                      = "premium"
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  public_network_access_enabled = true # Enabled due to laptop access needed to lab
  soft_delete_retention_days    = 7
  enable_rbac_authorization     = false
  tags                          = local.tags

  network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"
    virtual_network_subnet_ids = [azurerm_subnet.agw.id,
    ]
    ip_rules = ["98.96.101.244", "104.225.182.52"]
  }

}

resource "azurerm_key_vault_access_policy" "self" {
  key_vault_id = azurerm_key_vault.certificates.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  certificate_permissions = [
    "Backup",
    "Create",
    "Delete",
    "DeleteIssuers",
    "Get",
    "GetIssuers",
    "Import",
    "List",
    "ListIssuers",
    "ManageContacts",
    "ManageIssuers",
    "Purge",
    "Recover",
    "Restore",
    "SetIssuers",
    "Update",
  ]

  secret_permissions = [
    "Backup",
    "Delete",
    "Get",
    "List",
    "Purge",
    "Recover",
    "Restore",
    "Set",
  ]
}