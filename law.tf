resource "azurerm_log_analytics_workspace" "this" {
  name                = "stg-law"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  sku                 = "PerGB2018"
  tags                = local.tags
}

locals {
  diag_resources = [
    "azurerm_public_ip.this.id",
    "azurerm_virtual_network.this.id",
    "azurerm_storage_account.this.id",
    "${azurerm_storage_account.this.id}/blobServices/default/",
    "azurerm_application_gateway.this.id",
    "azurerm_key_vault.certificates.id",
    "azurerm_key_vault.storage.id",
    "azurerm_log_analytics_workspace.this.id",
  ]
}

data "azurerm_monitor_diagnostic_categories" "this" {
  for_each    = local.diag_resources
  resource_id = each.value
}

# resource "azurerm_monitor_diagnostic_setting" "vnet" {
#   for_each                   - local.diag_resources
#   name                       = "central-diag"
#   target_resource_id         = each.value
#   log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id

#   dynamic "enabled_log" {
#     for_each = data.azurerm_monitor_diagnostic_categories.this[each.value].log_category_types
#     content {
#       category = enabled_log.value

#       retention_policy {
#         enabled = false
#       }
#     }
#   }

#   dynamic "metric" {
#     for_each = data.azurerm_monitor_diagnostic_categories.this[each.value].metrics
#     content {
#       category = metric.value

#       retention_policy {
#         enabled = true
#       }
#     }
#   }
# }


# data "azurerm_monitor_diagnostic_categories" "pip" {
#   resource_id = azurerm_public_ip.this.id
# }

# data "azurerm_monitor_diagnostic_categories" "vnet" {
#   resource_id = azurerm_virtual_network.this.id
# }

# data "azurerm_monitor_diagnostic_categories" "storage" {
#   resource_id = azurerm_storage_account.this.id
# }

# data "azurerm_monitor_diagnostic_categories" "storage_blob" {
#   resource_id = "${azurerm_storage_account.this.id}/blobServices/default/"
# }

# data "azurerm_monitor_diagnostic_categories" "agw" {
#   resource_id = azurerm_application_gateway.this.id
# }

# data "azurerm_monitor_diagnostic_categories" "akv" {
#   resource_id = azurerm_key_vault.certificates.id
# }

# data "azurerm_monitor_diagnostic_categories" "law" {
#   resource_id = azurerm_log_analytics_workspace.this.id
# }

# resource "azurerm_monitor_diagnostic_setting" "vnet" {
#   name                       = "vnet-diag"
#   target_resource_id         = azurerm_virtual_network.this.id
#   log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id

#   dynamic "enabled_log" {
#     for_each = data.azurerm_monitor_diagnostic_categories.vnet.log_category_types
#     content {
#       category = enabled_log.value

#       retention_policy {
#         enabled = false
#       }
#     }
#   }

#   dynamic "metric" {
#     for_each = data.azurerm_monitor_diagnostic_categories.vnet.metrics
#     content {
#       category = metric.value

#       retention_policy {
#         enabled = true
#       }
#     }
#   }
# }

# resource "azurerm_monitor_diagnostic_setting" "pip" {
#   name                       = "pip-diag"
#   target_resource_id         = azurerm_public_ip.this.id
#   log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id

#   dynamic "enabled_log" {
#     for_each = data.azurerm_monitor_diagnostic_categories.pip.log_category_types
#     content {
#       category = enabled_log.value

#       retention_policy {
#         enabled = false
#       }
#     }
#   }

#   dynamic "metric" {
#     for_each = data.azurerm_monitor_diagnostic_categories.pip.metrics
#     content {
#       category = metric.value

#       retention_policy {
#         enabled = true
#       }
#     }
#   }
# }

# resource "azurerm_monitor_diagnostic_setting" "storage_blob" {
#   name                       = "storage-diag"
#   target_resource_id         = "${azurerm_storage_account.this.id}/blobServices/default/"
#   log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id

#   dynamic "enabled_log" {
#     for_each = data.azurerm_monitor_diagnostic_categories.storage_blob.log_category_types
#     content {
#       category = enabled_log.value

#       retention_policy {
#         enabled = false
#       }
#     }
#   }

#   dynamic "metric" {
#     for_each = data.azurerm_monitor_diagnostic_categories.storage_blob.metrics
#     content {
#       category = metric.value

#       retention_policy {
#         enabled = true
#       }
#     }
#   }
# }

# resource "azurerm_monitor_diagnostic_setting" "storage" {
#   name                       = "storage-diag"
#   target_resource_id         = azurerm_storage_account.this.id
#   log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id

#   dynamic "enabled_log" {
#     for_each = data.azurerm_monitor_diagnostic_categories.storage.log_category_types
#     content {
#       category = enabled_log.value

#       retention_policy {
#         enabled = false
#       }
#     }
#   }

#   dynamic "metric" {
#     for_each = data.azurerm_monitor_diagnostic_categories.storage.metrics
#     content {
#       category = metric.value

#       retention_policy {
#         enabled = true
#       }
#     }
#   }
# }

# resource "azurerm_monitor_diagnostic_setting" "akv-ssl" {
#   name                       = "akv-diag"
#   target_resource_id         = azurerm_key_vault.certificates.id
#   log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id

#   dynamic "enabled_log" {
#     for_each = data.azurerm_monitor_diagnostic_categories.akv.log_category_types
#     content {
#       category = enabled_log.value

#       retention_policy {
#         enabled = false
#       }
#     }
#   }

#   dynamic "metric" {
#     for_each = data.azurerm_monitor_diagnostic_categories.akv.metrics
#     content {
#       category = metric.value

#       retention_policy {
#         enabled = true
#       }
#     }
#   }
# }

# resource "azurerm_monitor_diagnostic_setting" "akv-storage" {
#   name                       = "akv-diag"
#   target_resource_id         = azurerm_key_vault.storage.id
#   log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id

#   dynamic "enabled_log" {
#     for_each = data.azurerm_monitor_diagnostic_categories.akv.log_category_types
#     content {
#       category = enabled_log.value

#       retention_policy {
#         enabled = false
#       }
#     }
#   }

#   dynamic "metric" {
#     for_each = data.azurerm_monitor_diagnostic_categories.akv.metrics
#     content {
#       category = metric.value

#       retention_policy {
#         enabled = true
#       }
#     }
#   }
# }

# resource "azurerm_monitor_diagnostic_setting" "law" {
#   name                       = "law-diag"
#   target_resource_id         = azurerm_log_analytics_workspace.this.id
#   log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id

#   dynamic "enabled_log" {
#     for_each = data.azurerm_monitor_diagnostic_categories.law.log_category_types
#     content {
#       category = enabled_log.value

#       retention_policy {
#         enabled = false
#       }
#     }
#   }

#   dynamic "metric" {
#     for_each = data.azurerm_monitor_diagnostic_categories.law.metrics
#     content {
#       category = metric.value

#       retention_policy {
#         enabled = true
#       }
#     }
#   }
# }

# resource "azurerm_monitor_diagnostic_setting" "agw" {
#   name                       = "agw-diag"
#   target_resource_id         = azurerm_application_gateway.this.id
#   log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id

#   dynamic "enabled_log" {
#     for_each = data.azurerm_monitor_diagnostic_categories.agw.log_category_types
#     content {
#       category = enabled_log.value

#       retention_policy {
#         enabled = false
#       }
#     }
#   }

#   dynamic "metric" {
#     for_each = data.azurerm_monitor_diagnostic_categories.agw.metrics
#     content {
#       category = metric.value

#       retention_policy {
#         enabled = true
#       }
#     }
#   }
# }