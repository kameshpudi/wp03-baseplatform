locals {
  global_vars           = read_terragrunt_config(find_in_parent_folders("global-vars.hcl"))
  region_vars           = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  env_vars              = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  module_version        = local.env_vars.locals.module_version
  resource_tags         = { "arch" = "log-analytics:${local.module_version}", "infra_region" = "${local.region_vars.locals.infra_region}", "env" = "${local.env_vars.locals.env}" }
  tags                  = merge(local.global_vars.locals.tags, local.resource_tags)
  source_base_url       = "${local.global_vars.locals.source_base_url}//log_analytics"
  log_analytics_ws_name = replace("${local.global_vars.locals.resource_names.log_analytics_ws_name}", "$PLACEHOLDER", "${local.region_vars.locals.infra_region}-${local.env_vars.locals.env}")
}

dependencies {
  paths = ["${get_terragrunt_dir()}//../rg-logging"]
}

dependency "rg" {
  config_path = "${get_terragrunt_dir()}//../rg-logging"
  # Mock outputs in case resource is not existing. This allows to run terragrunt run-all plan or validate on non-existing
  # resources. More information can be found here https://terragrunt.gruntwork.io/docs/features/execute-terraform-commands-on-multiple-modules-at-once/#dependencies-between-modules
  mock_outputs = {
    rg_name = "MOCK-test-app-logging-rg"
  }
}

# terraform {
#   # Execute validation via tflint after a terraform plan or terraform validation was run
#   after_hook "tflint logaws" {
#     commands = ["validate", "plan"]
#     execute  = ["tflint"]
#   }
# }

inputs = {
  rg_name    = dependency.rg.outputs.rg_name
  location   = local.region_vars.locals.location
  tags       = local.tags
  workspaces = { "default-workspace" : { "sku" : "PerGB2018", "retention_in_days" : 30, internet_ingestion_enabled = true, internet_query_enabled = true } }
}