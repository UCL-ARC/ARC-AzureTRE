data "azurerm_subnet" "shared" {
  resource_group_name  = local.core_resource_group_name
  virtual_network_name = local.core_vnet
  name                 = "SharedSubnet"
}

data "azurerm_subnet" "web_apps" {
  resource_group_name  = local.core_resource_group_name
  virtual_network_name = local.core_vnet
  name                 = "WebAppSubnet"
}

data "azurerm_subnet" "mysql" {
  resource_group_name  = local.core_resource_group_name
  virtual_network_name = local.core_vnet
  name                 = "MySQLSubnet"
}

data "azurerm_key_vault" "core" {
  name                = local.keyvault_name
  resource_group_name = local.core_resource_group_name
}

data "azurerm_resource_group" "core" {
  name = local.core_resource_group_name
}

data "azurerm_service_plan" "core" {
  name                = local.asp_name
  resource_group_name = local.core_resource_group_name
}

data "azurerm_container_registry" "mgmt" {
  name                = var.mgmt_acr_name
  resource_group_name = var.mgmt_resource_group_name
}

data "azurerm_application_insights" "core" {
  name                = local.app_insights_name
  resource_group_name = local.core_resource_group_name
}

