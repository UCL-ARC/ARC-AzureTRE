resource "azurerm_linux_web_app" "redcap" {
  name                      = "app-redcap-${var.tre_id}"
  location                  = data.azurerm_resource_group.core.location
  resource_group_name       = data.azurerm_resource_group.core.name
  tags                      = local.tags
  service_plan_id           = data.azurerm_service_plan.core.id
  https_only                = true
  virtual_network_subnet_id = data.azurerm_subnet.all["WebAppSubnet"].id

  identity {
    type = "SystemAssigned"
  }

  site_config {
    always_on                               = true
    container_registry_use_managed_identity = true

    application_stack {
      docker_image     = "${data.azurerm_container_registry.mgmt.login_server}/${local.redcap_docker_image}"
      docker_image_tag = local.redcap_docker_image_tag
    }

    default_documents = [
      "index.php",
      "Default.htm",
      "Default.html",
      "Default.asp",
      "index.htm",
      "index.html",
      "iisstart.htm",
      "default.aspx",
      "hostingstart.html",
    ]
  }

  app_settings = {
    "StorageContainerName"                            = "redcap" # Created automatically
    "StorageAccount"                                  = azurerm_storage_account.redcap.name
    "StorageKey"                                      = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.all["storage-account-key"].id})"
    "DBHostName"                                      = azurerm_mysql_flexible_server.redcap.fqdn
    "DBName"                                          = local.mysql_database_name
    "DBUserName"                                      = local.mysql_admin_username
    "DBPassword"                                      = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.all["mysql-password"].id})"
    "DBSslCa"                                         = "/home/site/wwwroot/DigiCertGlobalRootCA.crt.pem"
    "PHP_INI_SCAN_DIR"                                = "/usr/local/etc/php/conf.d:/home/site"
    "fromEmailAddress"                                = "NOT_USED"
    "smtpFQDN"                                        = "NOT_USED"
    "smtpPort"                                        = "NOT_USED"
    "smtpUsername"                                    = "NOT_USED"
    "smtpPassword"                                    = "NOT_USED"
    "APPINSIGHTS_INSTRUMENTATIONKEY"                  = data.azurerm_application_insights.redcap.instrumentation_key
    "APPINSIGHTS_PROFILERFEATURE_VERSION"             = "1.0.0"
    "APPINSIGHTS_SNAPSHOTFEATURE_VERSION"             = "1.0.0"
    "APPLICATIONINSIGHTS_CONNECTION_STRING"           = data.azurerm_application_insights.redcap.connection_string
    "ApplicationInsightsAgent_EXTENSION_VERSION"      = "~2"
    "DiagnosticServices_EXTENSION_VERSION"            = "~3"
    "PORT"                                            = 8080
    "WEBSITES_PORT"                                   = 8080
    "WEBSITES_CONTAINER_START_TIME_LIMIT"             = 1000 # seconds
    "InstrumentationEngine_EXTENSION_VERSION"         = "disabled"
    "SnapshotDebugger_EXTENSION_VERSION"              = "disabled"
    "XDT_MicrosoftApplicationInsights_BaseExtensions" = "disabled"
    "XDT_MicrosoftApplicationInsights_Mode"           = "recommended"
    "XDT_MicrosoftApplicationInsights_PreemptSdk"     = "disabled"
  }

  logs {
    http_logs {
      file_system {
        retention_in_days = 7
        retention_in_mb   = 100 # range is between 25-100
      }
    }
  }

  depends_on = [
    azurerm_key_vault_secret.all
  ]
}

resource "azurerm_private_endpoint" "redcap_app" {
  name                = "pe-${azurerm_linux_web_app.redcap.name}"
  location            = data.azurerm_resource_group.core.location
  resource_group_name = data.azurerm_resource_group.core.name
  subnet_id           = data.azurerm_subnet.all["SharedSubnet"].id
  tags                = local.tags

  lifecycle { ignore_changes = [tags] }

  private_service_connection {
    private_connection_resource_id = azurerm_linux_web_app.redcap.id
    name                           = "psc-api-${azurerm_linux_web_app.redcap.name}"
    subresource_names              = ["sites"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-group-${azurerm_linux_web_app.redcap.name}"
    private_dns_zone_ids = [data.azurerm_private_dns_zone.all["webapp"].id]
  }
}

resource "azurerm_role_assignment" "webapp_can_pull_images" {
  role_definition_name = "AcrPull"
  scope                = data.azurerm_container_registry.mgmt.id
  principal_id         = azurerm_linux_web_app.redcap.identity[0].principal_id
}

resource "azurerm_role_assignment" "webapp_can_read_secrets" {
  role_definition_name = "Key Vault Secrets User"
  scope                = azurerm_key_vault.redcap.id
  principal_id         = azurerm_linux_web_app.redcap.identity[0].principal_id
}
