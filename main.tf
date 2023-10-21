locals {
  suffix            = "pvtstg"
  prefix            = "pvtstg"
  location          = "eastus"
  stg_rg_name       = "${module.naming.resource_group.name}-storage"
  dns_rg_name       = "${module.naming.resource_group.name}-dns"
  vnet_name         = module.naming.virtual_network.name
  stg_subnet_name   = "${module.naming.subnet.name}-stg"
  agw_subnet_name   = "${module.naming.subnet.name}-agw"
  pe_subnet_name    = "${module.naming.subnet.name}-pe"
  stg_account_name  = module.naming.storage_account.name_unique
  stg_pe_name       = "${module.naming.private_endpoint.name}-storage"
  stg_psc_name      = "${local.prefix}-stg-psc"
  akv_name          = module.naming.key_vault.name
  agw_name          = module.naming.application_gateway.name
  agw_identity_name = "${module.naming.user_assigned_identity.name}-agw"
  akv_pe_name       = "${module.naming.private_endpoint.name}-akv"
  akv_psc_name      = "${local.prefix}-akv-psc"
  agw_ssl_name      = "${local.prefix}-agw-ssl"
  agw_pip_name      = "${module.naming.public_ip.name}-pip"
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
  suffix        = [local.suffix]
  unique-length = 2
  unique-seed   = local.suffix
}

resource "azurerm_resource_group" "this" {
  # name     = local.rg_name
  name     = local.stg_rg_name
  location = local.location
  tags     = local.tags
}
