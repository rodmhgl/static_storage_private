resource "random_id" "storage_account" {
  byte_length = 1
}

resource "azurerm_storage_account" "this" {
  name                            = local.stg_account_name
  resource_group_name             = azurerm_resource_group.this.name
  location                        = azurerm_resource_group.this.location
  account_kind                    = "BlockBlobStorage" # StorageV2 or BlockBlobStorage
  account_tier                    = "Premium"
  account_replication_type        = "LRS"
  min_tls_version                 = "TLS1_2"
  enable_https_traffic_only       = true
  public_network_access_enabled   = false
  allow_nested_items_to_be_public = false
  tags                            = local.tags

  network_rules {
    default_action             = "Deny"
    virtual_network_subnet_ids = [azurerm_subnet.agw.id, azurerm_subnet.stg.id]

    # Added private_link_access to match the config in the lab - dataScanner added by security policy? 
    private_link_access {
      endpoint_resource_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/providers/Microsoft.Security/datascanners/storageDataScanner"
      endpoint_tenant_id   = data.azurerm_client_config.current.tenant_id
    }
  }

  static_website {
    index_document     = "index.htm"
    error_404_document = "not_real_yet.htm"
  }

}

resource "azurerm_private_endpoint" "stg_web" {
  name                = "${module.naming.private_endpoint.name}-storage-web"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = azurerm_subnet.pe.id
  tags                = local.tags

  private_service_connection {
    name                           = "${local.stg_account_name}-stg-web-psc"
    private_connection_resource_id = azurerm_storage_account.this.id
    subresource_names              = ["web"]
    is_manual_connection           = false
  }

  # private_dns_zone_group {
  #   name                 = "privatelink-blob-dns-zone-group"
  #   private_dns_zone_ids = [azurerm_private_dns_zone.privatelink_blob.id]
  # }

  private_dns_zone_group {
    name                 = "privatelink-web-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.privatelink_web.id]
  }

}

resource "azurerm_private_endpoint" "stg_blob" {
  name                = "${module.naming.private_endpoint.name}-storage-blob"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = azurerm_subnet.pe.id
  tags                = local.tags

  private_service_connection {
    name                           = "${local.stg_account_name}-stg-blob-psc"
    private_connection_resource_id = azurerm_storage_account.this.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "privatelink-blob-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.privatelink_blob.id]
  }

}
