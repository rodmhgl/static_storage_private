resource "azurerm_resource_group" "dns" {
  name     = local.dns_rg_name
  location = local.location
  tags     = local.tags
}

resource "azurerm_private_dns_zone" "privatelink_blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.dns.name
  tags                = local.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "blob" {
  name                  = "privatelink.blob.core.windows.net-link"
  private_dns_zone_name = azurerm_private_dns_zone.privatelink_blob.name
  resource_group_name   = azurerm_resource_group.dns.name
  virtual_network_id    = azurerm_virtual_network.this.id
  tags                  = local.tags
}

resource "azurerm_private_dns_zone" "privatelink_vaultcore" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.dns.name
  tags                = local.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "vaultcore" {
  name                  = "privatelink.vaultcore.azure.net-link"
  private_dns_zone_name = azurerm_private_dns_zone.privatelink_vaultcore.name
  resource_group_name   = azurerm_resource_group.dns.name
  virtual_network_id    = azurerm_virtual_network.this.id
  tags                  = local.tags
}

resource "azurerm_private_dns_zone" "privatelink_web" {
  name                = "privatelink.web.core.windows.net"
  resource_group_name = azurerm_resource_group.dns.name
  tags                = local.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "web" {
  name                  = "privatelink.web.core.windows.net-link"
  private_dns_zone_name = azurerm_private_dns_zone.privatelink_web.name
  resource_group_name   = azurerm_resource_group.dns.name
  virtual_network_id    = azurerm_virtual_network.this.id
  tags                  = local.tags
}