resource "azurerm_user_assigned_identity" "agw_cert_read" {
  name                = "${module.naming.user_assigned_identity.name}-agw"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  tags                = local.tags
}

resource "azurerm_key_vault_access_policy" "agw_identity" {
  key_vault_id       = azurerm_key_vault.certificates.id
  object_id          = azurerm_user_assigned_identity.agw_cert_read.principal_id
  tenant_id          = data.azurerm_client_config.current.tenant_id
  secret_permissions = ["Get"]
}

resource "azurerm_key_vault_certificate" "this_https" {
  name         = module.naming.key_vault_certificate.name_unique
  key_vault_id = azurerm_key_vault.certificates.id
  certificate {
    contents = filebase64(var.certificate_path)
    password = var.certificate_password
  }
  depends_on = [
    azurerm_key_vault_access_policy.self,
    azurerm_private_endpoint.akv
  ]
}

resource "azurerm_key_vault" "certificates" {
  name                          = local.akv_name
  resource_group_name           = azurerm_resource_group.this.name
  location                      = azurerm_resource_group.this.location
  sku_name                      = "premium"
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  public_network_access_enabled = true # Enabled due to laptop access needed to lab
  purge_protection_enabled      = false
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

resource "azurerm_private_endpoint" "akv" {
  name                = "${module.naming.private_endpoint.name}-akv"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = azurerm_subnet.pe.id
  tags                = local.tags

  private_service_connection {
    name                           = "${local.akv_name}-psc"
    private_connection_resource_id = azurerm_key_vault.certificates.id
    subresource_names              = ["Vault"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "privatelink-vault-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.privatelink_vaultcore.id]
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
