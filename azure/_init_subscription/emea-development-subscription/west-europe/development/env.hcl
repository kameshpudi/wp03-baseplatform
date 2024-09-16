locals {
  region_vars       = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  env               = "development"
  env_prefix        = "d"
  resource_prefix   = "${local.env_prefix}-${local.region_vars.locals.region_prefix}"
  module_version    = "v1.0.0"
}