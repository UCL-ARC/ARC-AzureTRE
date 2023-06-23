resource "azurerm_storage_account" "redcap" {
  name                     = "strgredcap${var.tre_id}"
  location                 = data.azurerm_resource_group.core.location
  resource_group_name      = data.azurerm_resource_group.core.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = local.tags

  network_rules {
    default_action = "Deny"

    bypass = [
      "AzureServices",
      "Logging",
      "Metrics"
    ]
  }
}

resource "azurerm_private_endpoint" "blob" {
  name                = "pe-${azurerm_storage_account.redcap.name}"
  location            = data.azurerm_resource_group.core.location
  resource_group_name = data.azurerm_resource_group.core.name
  tags                = local.tags
  subnet_id           = data.azurerm_subnet.all["SharedSubnet"].id

  private_dns_zone_group {
    name                 = "dns-zone-group-strg"
    private_dns_zone_ids = [data.azurerm_private_dns_zone.all["blob"].id]
  }

  private_service_connection {
    name                           = "pe-service-connection-strg"
    private_connection_resource_id = azurerm_storage_account.redcap.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }
}
