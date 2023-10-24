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
    fqdns = ["${azurerm_storage_account.this.name}.privatelink.web.core.windows.net"]
  }

  backend_http_settings {
    name                                = local.http_setting_name
    host_name                           = "${azurerm_storage_account.this.name}.z13.web.core.windows.net"
    cookie_based_affinity               = "Disabled"
    path                                = "/"
    port                                = 443
    protocol                            = "Https"
    request_timeout                     = 60
    probe_name                          = "https_health_probe"
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
    ssl_certificate_name           = "${local.agw_ssl_name}-cert"
  }

  probe {
    interval                                  = 30
    name                                      = "https_health_probe"
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
    name                = "${local.agw_ssl_name}-cert"
    key_vault_secret_id = azurerm_key_vault_certificate.this_https.secret_id
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.agw_cert_read.id]
  }

  depends_on = [
    azurerm_key_vault_access_policy.agw_identity,
    azurerm_key_vault_certificate.this_https,
    azurerm_private_endpoint.akv
  ]
}

# Stack:
# Network / Subnets / DNS
# Key Vault / AKV Access Policy (Self)
# Storage
# Certificate Placement
# Public IP / User Assigned Identity / AKV Access Policy (UAI) / App Gateway

# sudo certbot certonly --manual \
#   --preferred-challenges dns \
#   -d "storage-agw.azurelaboratory.com" \
#   --register-unsafely-without-email \
#   --agree-tos \
#   --test-cert \
#   --manual-auth-hook "./validate.sh" \
#   --manual-cleanup-hook "./cleanup.sh" \
#   --deploy-hook "./deploy.sh" \
#   --disable-hook-validation \
#   --logs-dir "/opt/certbot/log" \
#   --work-dir "/opt/certbot/lib" \
#   --config-dir "/opt/certbot/letsencrypt"

# sudo openssl pkcs12 -export \
# -out ~/pkcs12_cert.pfx \
# -inkey ./privkey.pem \
# -in ./cert.pem \
# -certfile ./chain.pem