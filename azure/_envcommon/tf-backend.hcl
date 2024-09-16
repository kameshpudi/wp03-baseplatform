
locals {
  global_vars     = read_terragrunt_config(find_in_parent_folders("global-vars.hcl"))
  region_vars     = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  env_vars        = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  module_version  = local.env_vars.locals.module_version
  local_tag_info  = { "arch" = "terraform_azure_backend:${local.module_version}", "infra_region" = "${local.region_vars.locals.infra_region}", "env" = "${local.env_vars.locals.env}" } # Local tags
  tags            = merge(local.global_vars.locals.tags, local.local_tag_info)                                                                                                      # Extend global tags with local ones
  base_name       = "${local.env_vars.locals.resource_prefix}-${local.global_vars.locals.resource_names.tf_backend_name}"
  source_base_url = "${local.global_vars.locals.source_base_url}//terraform_azure_backend"
  ip_rules        = local.global_vars.locals.networking["${local.region_vars.locals.infra_region}"]
  subnet_ids      = local.env_vars.locals.subnet_ids
}

remote_state {
  backend = "local"
  config  = {}
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

inputs = {
  rg_name                                            = "${local.base_name}-rg"
  storage_name                                       = replace("${local.env_vars.locals.env_prefix}${local.tags.name}tfstate", "-", "")
  location                                           = local.region_vars.locals.location
  sku                                                = "Premium"
  tags                                               = local.tags
  storage_account_allowed_ips                        = local.ip_rules
  storage_account_allowed_virtual_network_subnet_ids = local.subnet_ids
}

