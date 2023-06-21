resource "azurerm_key_vault_secret" "all" {
  for_each     = local.secrets
  name         = each.key
  value        = each.value
  key_vault_id = azurerm_key_vault.redcap.id

  depends_on = [
    azurerm_role_assignment.deployer_can_administrate_kv,
    null_resource.wait_for_keyvault_pe
   ]
}
