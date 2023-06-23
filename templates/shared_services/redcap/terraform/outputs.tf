output "connection_uri" {
  value = "https://${azurerm_linux_web_app.redcap.default_hostname}"
}
