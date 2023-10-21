resource "azurerm_virtual_network" "this" {
  name                = local.vnet_name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.tags
}

resource "azurerm_subnet" "stg" {
  name                 = local.stg_subnet_name
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  service_endpoints    = ["Microsoft.Storage"]
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "agw" {
  name                 = local.agw_subnet_name
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  service_endpoints    = ["Microsoft.Storage"]
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "pe" {
  name                 = local.pe_subnet_name
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  service_endpoints    = ["Microsoft.Storage"]
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_private_endpoint" "stg" {
  name                = local.stg_pe_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = azurerm_subnet.pe.id
  tags                = local.tags

  private_service_connection {
    name                           = local.stg_psc_name
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