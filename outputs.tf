output "agw_public_ip" {
  value = azurerm_public_ip.this.ip_address
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
