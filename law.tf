resource "azurerm_log_analytics_workspace" "this" {
  name                = "stg-law"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  sku                 = "PerGB2018"
  tags                = local.tags
}

locals {
  diag_resources = toset([
    azurerm_public_ip.this.id,
    azurerm_virtual_network.this.id,
    azurerm_storage_account.this.id,
    "${azurerm_storage_account.this.id}/blobServices/default/",
    azurerm_application_gateway.this.id,
    azurerm_key_vault.certificates.id,
    azurerm_key_vault.storage.id,
    azurerm_log_analytics_workspace.this.id,
  ])
}

data "azurerm_monitor_diagnostic_categories" "this" {
  for_each    = local.diag_resources
  resource_id = each.key
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  for_each                       = local.diag_resources
  name                           = "central-diag"
  target_resource_id             = each.key
  log_analytics_workspace_id     = azurerm_log_analytics_workspace.this.id
  log_analytics_destination_type = "Dedicated"

  dynamic "enabled_log" {
    for_each = data.azurerm_monitor_diagnostic_categories.this[each.value].log_category_types
    content {
      category = enabled_log.value

      retention_policy {
        enabled = false
      }
    }
  }

  dynamic "metric" {
    for_each = data.azurerm_monitor_diagnostic_categories.this[each.value].metrics
    content {
      category = metric.value

      retention_policy {
        enabled = true
      }
    }
  }
}
