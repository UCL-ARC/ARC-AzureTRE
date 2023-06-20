data "azurerm_client_config" "current" {}

data "azurerm_subnet" "all" {
  for_each             = toset(local.subnet_names)
  resource_group_name  = local.core_resource_group_name
  virtual_network_name = local.core_vnet
  name                 = each.key
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

data "azurerm_private_dns_zone" "all" {
  for_each            = local.dns_zones
  name                = each.value
  resource_group_name = local.core_resource_group_name
}

data "azurerm_application_insights" "redcap" {
  name                = local.app_insights_name
  resource_group_name = local.core_resource_group_name
}
