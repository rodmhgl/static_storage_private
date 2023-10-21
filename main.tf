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

module "naming" {
  source        = "Azure/naming/azurerm"
  version       = "0.3.0"
  suffix        = [local.prefix]
  unique-length = 2
  unique-seed   = local.prefix
}

resource "azurerm_resource_group" "this" {
  name     = local.rg_name
  location = local.location
  tags     = local.tags
}
