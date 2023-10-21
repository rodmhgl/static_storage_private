locals {
  prefix            = "pvtstg"
  location          = "eastus"
  rg_name           = "${local.prefix}-rg"
  dns_rg_name       = "${local.prefix}-dns-rg"
  vnet_name         = "${local.prefix}-vnet"
  stg_subnet_name   = "${local.prefix}-stg"
  agw_subnet_name   = "${local.prefix}-agw"
  pe_subnet_name    = "${local.prefix}-pe"
  stg_account_name  = "${local.prefix}${lower(random_id.storage_account.hex)}"
  stg_pe_name       = "${local.prefix}-stg-pe"
  stg_psc_name      = "${local.prefix}-stg-psc"
  akv_name          = "${local.prefix}-akv"
  agw_name          = "${local.prefix}-agw"
  agw_identity_name = "${local.prefix}-agw-id"
  akv_pe_name       = "${local.prefix}-akv-pe"
  akv_psc_name      = "${local.prefix}-akv-psc"
  agw_ssl_name      = "${local.prefix}-agw-ssl"
  tags = {
    environment = "lab"
    purpose     = "testing_static_cdn"
    created_by  = "rstewart@manubank.com"
    EAINO       = "98765"
    SAMPLE      = "TEST"
  }
}

resource "azurerm_resource_group" "this" {
  name     = local.rg_name
  location = local.location
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
  enable_https_traffic_only     = true
  min_tls_version               = "TLS1_2"
  public_network_access_enabled = false
  tags                          = local.tags

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

module "naming" {
  source        = "Azure/naming/azurerm"
  version       = "0.3.0"
  suffix        = [local.prefix]
  unique-length = 2
  unique-seed   = local.prefix
}

output "naming_app_gw" {
  value = module.naming.application_gateway.name
}


output "naming_akv" {
  value = module.naming.key_vault.name
}

output "naming_akv_secret" {
  value = module.naming.key_vault_secret.name
}

output "naming_public_ip_prefix" {
  value = module.naming.public_ip_prefix.name
}

output "naming_public_ip" {
  value = module.naming.public_ip.name
}

output "naming_vnet" {
  value = module.naming.private_endpoint.name
}

output "naming_storage" {
  value = module.naming.storage_account.name
}

output "naming_storage_unique" {
  value = module.naming.storage_account.name_unique
}

output "naming_rg" {
  value = module.naming.resource_group.name
}
