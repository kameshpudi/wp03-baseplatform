locals {
  global_vars     = read_terragrunt_config(find_in_parent_folders("global-vars.hcl"))
  region_vars     = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  env_vars        = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  module_version  = local.env_vars.locals.module_version
  resource_tags   = { "arch" = "storage-account:${local.module_version}", "infra_region" = "${local.region_vars.locals.infra_region}", "env" = "${local.env_vars.locals.env}" }
  tags            = merge(local.global_vars.locals.tags, local.resource_tags)
  resource_name   = replace("${local.env_vars.locals.resource_prefix}${local.global_vars.locals.resource_names.storage_account_name}", "-", "")
  source_base_url = "${local.global_vars.locals.source_base_url}//storage_account"
  # ip_rules        = local.global_vars.locals.networking["${local.region_vars.locals.infra_region}"]
  # subnet_ids      = local.env_vars.locals.subnet_ids
}


terraform {
  # Execute validation via tflint after a terraform plan or terraform validation was run
  after_hook "tflint storage" {
    commands = ["validate", "plan"]
    execute  = ["tflint"]
  }
}

inputs = {
  rg_name                                            = dependency.rg.outputs.rg_name
  name                                               = local.resource_name
  azure_location                                     = local.region_vars.locals.location
  tags                                               = local.tags
  ip_rules                                           = local.ip_rules
  subnet_ids                                         = local.subnet_ids
  storage_replication_type                           = "LRS"
  storage_account_allowed_ips                        = local.ip_rules
  storage_account_allowed_virtual_network_subnet_ids = local.subnet_ids
}