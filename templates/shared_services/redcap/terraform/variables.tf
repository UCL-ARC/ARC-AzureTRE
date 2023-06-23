variable "tre_id" {
  type        = string
  description = "Unique TRE ID"
}

variable "tre_resource_id" {
  type        = string
  description = "Resource ID"
}

variable "mgmt_acr_name" {
  type        = string
  description = "Azure container registry name containing the REDCap image"
}

variable "mgmt_resource_group_name" {
  type        = string
  description = "Resource group name containing the management ACR"
}

variable "redcap_image_path" {
  type        = string
  description = "Path to the redcap image within the ACR (mgmt_acr_name). e.g. redcap/redcap:latest"
}
