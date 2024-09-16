locals {
  global_vars      = read_terragrunt_config(find_in_parent_folders("global-vars.hcl"))
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  env_vars         = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  module_version   = local.env_vars.locals.module_version
  resource_tags    = { "arch" = "mssql:${local.module_version}", "infra_region" = "${local.region_vars.locals.infra_region}", "env" = "${local.env_vars.locals.env}" }
  tags             = merge(local.global_vars.locals.tags, local.resource_tags)
  resource_name    = replace("${local.env_vars.locals.resource_prefix}${local.global_vars.locals.resource_names.mssql}", "-", "")
  source_base_url  = "${local.global_vars.locals.source_base_url}//mssql"
  ip_rules         = local.global_vars.locals.networking["${local.region_vars.locals.infra_region}_mssql"]
  db_name          = "aiqx-${local.env_vars.locals.env}-${local.region_vars.locals.infra_region}"
  mysql_vnet_rules = local.env_vars.locals.mysql_vnet_rules
}

dependencies {
  paths = ["${get_terragrunt_dir()}//../rg-persistence", "${get_terragrunt_dir()}//../key-vault"]
}

dependency "rg" {
  config_path = "${get_terragrunt_dir()}//../rg-persistence"
  # Mock outputs in case resource is not existing. This allows to run terragrunt run-all plan or validate on non-existing
  # resources. More information can be found here https://terragrunt.gruntwork.io/docs/features/execute-terraform-commands-on-multiple-modules-at-once/#dependencies-between-modules
  mock_outputs = {
    rg_name = "MOCK-aiqx-app-persistence-rg"
  }
}

dependency "kv" {
  config_path = "${get_terragrunt_dir()}//../key-vault"
  # Mock outputs in case resource is not existing. This allows to run terragrunt run-all plan or validate on non-existing
  # resources. More information can be found here https://terragrunt.gruntwork.io/docs/features/execute-terraform-commands-on-multiple-modules-at-once/#dependencies-between-modules
  mock_outputs = {
    kv_id = "/subscriptions/ca11ff88-5653-482c-b4dd-XXXXXXXXXXXXXXX/resourceGroups/mykvrg/providers/Microsoft.KeyVault/vaults/mysuperkeyvaultmock"
  }
}

terraform {
  # Execute validation via tflint after a terraform plan or terraform validation was run
  after_hook "tflint mssql" {
    commands = ["validate", "plan"]
    execute  = ["tflint"]
  }
}

inputs = {
  rg_name             = dependency.rg.outputs.rg_name
  mssql_name          = local.resource_name
  key_vault_id        = dependency.kv.outputs.kv_id
  tags                = local.tags
  mssql_database_name = local.db_name
  azure_location      = local.region_vars.locals.location
  ip_firewall_rules   = local.ip_rules
  vnet_network_rules  = local.mysql_vnet_rules
}