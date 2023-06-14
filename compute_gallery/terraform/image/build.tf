resource "azapi_resource" "image_template" {
  type      = "Microsoft.VirtualMachineImages/imageTemplates@2020-02-14"
  name      = var.template_name
  parent_id = var.resource_group_id
  location  = var.location

  body = jsonencode({
    identity = {
      type = "UserAssigned"
      userAssignedIdentities = {
        tostring(var.image_builder_id) = {}
      }
    }
    properties = {
      buildTimeoutInMinutes = 180,

      vmProfile = {
        vmSize = "Standard_DS2_v2"
      },
      source = {
        type      = "PlatformImage",
        publisher = var.base_image.publisher,
        offer     = var.base_image.offer,
        sku       = var.base_image.sku,
        version   = "latest"
      },
      customize = concat(
        [local.init_script_block],
        fileexists(local.customize_file_path) ? jsondecode(file(local.customize_file_path)) : []
      ),
      distribute = [
        {
          type           = "SharedImage",
          galleryImageId = "${azurerm_shared_image.image.id}",
          runOutputName  = "${var.image_definition}",
          artifactTags = {
            source    = "azureVmImageBuilder",
            baseosimg = "${var.base_image.sku}"
          },
          replicationRegions = [var.location],
          storageAccountType = "Standard_LRS"
        }
      ]
  } })

  tags = {
    "useridentity" = "enabled"
  }

  # Avoid 409 Conflict by always replacing
  lifecycle {
    replace_triggered_by = [
      null_resource.always_run
    ]
  }
}

resource "null_resource" "always_run" {
  triggers = {
    timestamp = timestamp()
  }
}
