locals {
  path_to_template_dir = "${path.module}/../../assets/${var.image_identifier}"
  init_script_lines    = split("\n", file("${local.path_to_template_dir}/${var.init_script}"))
  customize_file_path  = "${local.path_to_template_dir}/customize.json"

  init_script_block = [{
    type        = "PowerShell"
    name        = "setupVM"
    inline      = local.init_script_lines
    runAsSystem = true
    runElevated = true
  }, {
    type   = "Shell"
    name   = "setupVM"
    inline = local.init_script_lines
  }
  ][endswith(var.init_script, ".ps1") ? 0 : 1 ]
}
