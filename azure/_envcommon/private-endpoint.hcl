locals {
  global_vars     = read_terragrunt_config(find_in_parent_folders("global-vars.hcl"))
  env_vars        = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  module_version  = local.env_vars.locals.module_version
  resource_name   = "${local.env_vars.locals.resource_prefix}-${local.global_vars.locals.resource_names.private_endpoint_name}"
  source_base_url = "${local.global_vars.locals.source_base_url}//private_endpoint"
}

dependencies {
  paths = ["${get_terragrunt_dir()}//../acr", "${get_terragrunt_dir()}//../rg-network"]
}

dependency "acr" {
  config_path = "${get_terragrunt_dir()}//../acr" 
  # Mock outputs in case resource is not existing. This allows to run terragrunt run-all plan or validate on non-existing
  # resources. More information can be found here https://terragrunt.gruntwork.io/docs/features/execute-terraform-commands-on-multiple-modules-at-once/#dependencies-between-modules
  mock_outputs = {
    private_connection_resource_id = "MOCK-test-pvte"
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

dependency "rg" {
  config_path = "${get_terragrunt_dir()}//../rg-network"
  # Mock outputs in case resource is not existing. This allows to run terragrunt run-all plan or validate on non-existing
  # resources. More information can be found here https://terragrunt.gruntwork.io/docs/features/execute-terraform-commands-on-multiple-modules-at-once/#dependencies-between-modules
  mock_outputs = {
    rg_name = "MOCK-test-app-network-rg"
  }
}

# terraform {
#  # Execute validation via tflint after a terraform plan or terraform validation was run
#  after_hook "tflint private-endpoint" {
#    commands = ["validate", "plan"]
#    execute  = ["tflint"]
#  }
# }

inputs = {
  rg_name                         = dependency.rg.outputs.rg_name
  azure_location                  = local.env_vars.locals.region_vars.locals.location
  endpoint_name                   = local.resource_name
  private_endpoint_subnet_id      = local.env_vars.locals.subnet_id_runner
  tags                            = local.global_vars.locals.tags
  private_service_connection_name = ""
  private_connection_resource_id  = dependency.acr.outputs.private_connection_resource_id
}