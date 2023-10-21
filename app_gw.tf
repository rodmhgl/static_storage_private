locals {
  backend_address_pool_name      = "${azurerm_virtual_network.this.name}-beap"
  frontend_http_port_name        = "${azurerm_virtual_network.this.name}-http-feport"
  frontend_https_port_name       = "${azurerm_virtual_network.this.name}-https-feport"
  frontend_ip_configuration_name = "${azurerm_virtual_network.this.name}-feip"
  http_setting_name              = "${azurerm_virtual_network.this.name}-be-htst"
  http_listener_name             = "${azurerm_virtual_network.this.name}-httplstn"
  https_listener_name            = "${azurerm_virtual_network.this.name}-httpslstn"
  request_routing_rule_name      = "${azurerm_virtual_network.this.name}-rqrt"
}

resource "azurerm_application_gateway" "this" {
  name                = local.agw_name
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  tags                = local.tags

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "this-gateway-ip-config"
    subnet_id = azurerm_subnet.agw.id
  }

  frontend_port {
    name = local.frontend_http_port_name
    port = 80
  }

  frontend_port {
    name = local.frontend_https_port_name
    port = 443
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.this.id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
    # fqdns = [azurerm_storage_account.this.primary_web_host]
    fqdns = ["pvtstg6b.privatelink.web.core.windows.net"]
  }

  backend_http_settings {
    name                                = local.http_setting_name
    host_name                           = "pvtstg6b.web.core.windows.net"
    cookie_based_affinity               = "Disabled"
    path                                = "/"
    port                                = 443
    protocol                            = "Https"
    request_timeout                     = 60
    probe_name                          = "probe"
    pick_host_name_from_backend_address = false
  }

  http_listener {
    name                           = local.http_listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_http_port_name
    protocol                       = "Http"
  }

  http_listener {
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_https_port_name
    host_names                     = []
    name                           = local.https_listener_name
    protocol                       = "Https"
    require_sni                    = false
    ssl_certificate_name           = local.agw_ssl_name
  }

  probe {
    interval                                  = 30
    name                                      = "probe"
    protocol                                  = "Https" # Https
    path                                      = "/index.htm"
    timeout                                   = 60
    unhealthy_threshold                       = 2
    port                                      = 443
    pick_host_name_from_backend_http_settings = true

    match {
      status_code = ["200"]
    }
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    priority                   = 9
    rule_type                  = "Basic"
    http_listener_name         = local.https_listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }

  ssl_certificate {
    name                = local.agw_ssl_name
    key_vault_secret_id = azurerm_key_vault_secret.this_https.id
    # password            = var.certificate_password
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.agw_cert_read.id]
  }

  depends_on = [azurerm_key_vault_access_policy.agw_identity]
}

resource "azurerm_user_assigned_identity" "agw_cert_read" {
  name                = local.agw_identity_name
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  tags                = local.tags
}

resource "azurerm_key_vault_access_policy" "agw_identity" {
  key_vault_id       = azurerm_key_vault.certificates.id
  object_id          = azurerm_user_assigned_identity.agw_cert_read.client_id
  tenant_id          = data.azurerm_client_config.current.tenant_id
  secret_permissions = ["Get"]
  # certificate_permissions = [ "ManageContacts" ]
}

# convert pem to unencrypted pfx without keys
# openssl pkcs12 -export -nokeys -in ./cert.pem -out ~/upkcs12.pfx
resource "azurerm_key_vault_secret" "this_https" {
  name         = local.agw_ssl_name
  key_vault_id = azurerm_key_vault.certificates.id
  value        = filebase64(var.certificate_path)

  depends_on = [
    azurerm_key_vault_access_policy.self,
    azurerm_private_endpoint.akv
  ]
}
