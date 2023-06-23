locals {
  redcap_docker_image     = try(split(":", var.redcap_image_path)[0], var.redcap_image_path)
  redcap_docker_image_tag = try(split(":", var.redcap_image_path)[1], "latest")

  core_vnet                = "vnet-${var.tre_id}"
  core_resource_group_name = "rg-${var.tre_id}"
  keyvault_name            = "kv-${var.tre_id}"
  asp_name                 = "plan-${var.tre_id}"
  app_insights_name        = "appi-${var.tre_id}"

  mysql_admin_username = "adminuser"
  mysql_admin_password = random_password.mysql.result
  mysql_database_name  = "redcap_db"

  secrets = {
    mysql-password      = local.mysql_admin_password
    storage-account-key = azurerm_storage_account.redcap.primary_access_key
    connection-string   = "Database=${local.mysql_database_name};Data Source=${azurerm_mysql_flexible_server.redcap.fqdn};User Id=${local.mysql_admin_username}@${azurerm_mysql_flexible_server.redcap.name};Password=${local.mysql_admin_password}"
  }

  subnet_names = [
    "SharedSubnet",
    "WebAppSubnet",
    "MySQLSubnet"
  ]

  dns_zones = {
    blob     = "privatelink.blob.core.windows.net"
    file     = "privatelink.file.core.windows.net"
    mysql    = "privatelink.mysql.database.azure.com"
    keyvault = "privatelink.vaultcore.azure.net"
    webapp   = "privatelink.azurewebsites.net"
  }

  tags = {
    tre_id                = var.tre_id
    tre_shared_service_id = var.tre_resource_id
  }
}
