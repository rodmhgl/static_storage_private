locals {
  suffix           = "pvtstg"
  stg_account_name = module.naming.storage_account.name_unique
  akv_name         = module.naming.key_vault.name
  agw_name         = module.naming.application_gateway.name
  agw_ssl_name     = "${local.agw_name}-ssl"
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
  name     = "${module.naming.resource_group.name}-storage"
  location = var.location
  tags     = local.tags
}
