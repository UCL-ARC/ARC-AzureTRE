variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "image_identifier" {
  type = string
}

variable "image_gallery_name" {
  type = string
}

variable "image_definition" {
  type = string
}

variable "template_name" {
  type = string
}

variable "offer_name" {
  type = string
}

variable "publisher_name" {
  type = string
}

variable "sku" {
  type = string
}

variable "os_type" {
  type = string
}

variable "description" {
  type = string
}

variable "hyperv_version" {
  type = string
}

variable "image_builder_id" {
  type        = string
  description = "Resource ID of the image builder user assigned identity"
}

variable "init_script" {
  type        = string
  description = "Initialisation script. Either .sh or .ps1"
}

variable "base_image" {
  type = object({
    publisher = string
    offer     = string
    sku       = string
  })
}
