locals {
  global_vars     = read_terragrunt_config(find_in_parent_folders("global-vars.hcl"))
  region_vars     = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  env_vars        = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  config_vars     = read_terragrunt_config("config.hcl")
  module_version  = local.env_vars.locals.module_version
  resource_tags   = { "arch" = "rg:${local.module_version}", "infra_region" = "${local.region_vars.locals.infra_region}", "env" = "${local.env_vars.locals.env}" }
  tags            = merge(local.global_vars.locals.tags, local.resource_tags)
  resource_name   = "${local.env_vars.locals.resource_prefix}-${local.global_vars.locals.resource_names.rg_name_base}"
  source_base_url = "${local.global_vars.locals.source_base_url}//rg"
}

terraform {
  # Execute validation via tflint after a terraform plan or terraform validation was run
  after_hook "tflint rg" {
    commands = ["validate", "plan"]
    execute  = ["tflint"]
  }
}

inputs = {
  rg_name  = replace("${local.resource_name}", "$PLACEHOLDER", "${local.config_vars.locals.type}")
  location = local.region_vars.locals.location
  tags     = local.tags
}