locals {
  path_to_template_dir = "${path.module}/../../assets/${var.image_identifier}"
  init_script_path     = "${local.path_to_template_dir}/${var.init_script}"
  customize__file_path = "${local.path_to_template_dir}/customize.json"
}
