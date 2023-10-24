resource "azurerm_key_vault" "storage" {
  name                          = local.stg_akv_name
  resource_group_name           = azurerm_resource_group.this.name
  location                      = azurerm_resource_group.this.location
  sku_name                      = "premium"
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  public_network_access_enabled = true # Enabled due to laptop access needed to lab
  purge_protection_enabled      = true
  soft_delete_retention_days    = 7
  enable_rbac_authorization     = false
  tags                          = local.tags

  network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"
    virtual_network_subnet_ids = [
      azurerm_subnet.agw.id,
    ]
    ip_rules = ["98.96.101.244", "104.225.182.52"]
  }

}

resource "azurerm_key_vault_access_policy" "self_storage" {
  key_vault_id = azurerm_key_vault.storage.id
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

  key_permissions = [
    "List",
    "Get",
    "Create",
    "Delete",
    "Purge",
    "Recover",
    "GetRotationPolicy",
    "SetRotationPolicy",
    "UnwrapKey",
    "WrapKey"
  ]
}

resource "azurerm_key_vault_access_policy" "storage" {
  key_vault_id = azurerm_key_vault.storage.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_storage_account.this.identity[0].principal_id

  secret_permissions = ["Get"]
  key_permissions = [
    "Get",
    "UnwrapKey",
    "WrapKey"
  ]

}

resource "azurerm_storage_account_customer_managed_key" "storage" {
  storage_account_id = azurerm_storage_account.this.id
  key_vault_id       = azurerm_key_vault.storage.id
  key_name           = azurerm_key_vault_key.storage_cmk.name
}

resource "azurerm_key_vault_key" "storage_cmk" {
  name         = "cmk"
  key_vault_id = azurerm_key_vault.storage.id
  key_type     = "RSA"
  key_size     = 2048
  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey"
  ]

  depends_on = [
    azurerm_key_vault_access_policy.self_storage,
    azurerm_key_vault_access_policy.storage
  ]
}
