locals {
  tags = {
    environment = "lab"
    purpose     = "testing_static_cdn"
    created_by  = "rstewart@manubank.com"
    EAINO       = "98765"
    SAMPLE      = "TEST"
  }
  prefix           = "pvtstg"
  rg_name          = "${local.prefix}-rg"
  vnet_name        = "${local.prefix}-vnet"
  stg_subnet_name  = "${local.prefix}-stg"
  agw_subnet_name  = "${local.prefix}-agw"
  pe_subnet_name   = "${local.prefix}-pe"
  stg_account_name = "${local.prefix}${lower(random_id.storage_account.hex)}"
  stg_pe_name      = "${local.prefix}-stg-pe"
  stg_psc_name     = "${local.prefix}-stg-psc"
}

resource "azurerm_resource_group" "this" {
  name     = local.rg_name
  location = "eastus"
  tags     = local.tags
}

resource "random_id" "storage_account" {
  byte_length = 1
}

resource "azurerm_storage_account" "this" {
  name                          = local.stg_account_name
  resource_group_name           = azurerm_resource_group.this.name
  location                      = azurerm_resource_group.this.location
  account_kind                  = "StorageV2" # StorageV2 or BlockBlobStorage
  account_tier                  = "Standard"
  account_replication_type      = "LRS"
  enable_https_traffic_only     = false # will need to test with true once we have certificate
  min_tls_version               = "TLS1_2"
  public_network_access_enabled = false
  tags                          = local.tags

  network_rules {
    default_action             = "Deny"
    virtual_network_subnet_ids = [azurerm_subnet.agw.id, azurerm_subnet.stg.id]
  }

  custom_domain {
    name = "storage.azurelaboratory.com"
    # use_subdomain = true
  }

  static_website {
    index_document     = "index.htm"
    error_404_document = "not_real_yet.htm"
  }

}
