resource "azurerm_public_ip" "this" {
  name                = "${module.naming.public_ip.name}-pip"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.tags
}

resource "azurerm_virtual_network" "this" {
  name                = module.naming.virtual_network.name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.tags
}

resource "azurerm_subnet" "agw" {
  name                 = "${module.naming.subnet.name}-agw"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  service_endpoints    = ["Microsoft.Storage", "Microsoft.KeyVault"]
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "pe" {
  name                 = "${module.naming.subnet.name}-pe"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  service_endpoints    = ["Microsoft.Storage", "Microsoft.KeyVault"]
  address_prefixes     = ["10.0.2.0/24"]
}
