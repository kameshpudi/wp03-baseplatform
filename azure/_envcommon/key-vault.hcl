locals {
  global_vars     = read_terragrunt_config(find_in_parent_folders("global-vars.hcl"))
  region_vars     = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  env_vars        = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  module_version  = local.env_vars.locals.module_version
  resource_tags   = { "arch" = "key-vault:${local.module_version}", "infra_region" = "${local.region_vars.locals.infra_region}", "env" = "${local.env_vars.locals.env}" }
  tags            = merge(local.global_vars.locals.tags, local.resource_tags)
  resource_name   = replace("${local.env_vars.locals.resource_prefix}${local.global_vars.locals.resource_names.kv_name}", "-", "")
  source_base_url = "${local.global_vars.locals.source_base_url}//key_vault"
  ip_rules        = local.global_vars.locals.networking["${local.region_vars.locals.infra_region}"]
  subnet_ids      = local.env_vars.locals.subnet_ids
}

dependencies {
  paths = ["${get_terragrunt_dir()}//../rg-persistence"]
}

dependency "rg" {
  config_path = "${get_terragrunt_dir()}//../rg-persistence"
  # Mock outputs in case resource is not existing. This allows to run terragrunt run-all plan or validate on non-existing
  # resources. More information can be found here https://terragrunt.gruntwork.io/docs/features/execute-terraform-commands-on-multiple-modules-at-once/#dependencies-between-modules
  mock_outputs = {
    rg_name = "MOCK-test-app-persistence-rg"
  }
}

# terraform {
#   # Execute validation via tflint after a terraform plan or terraform validation was run
#   after_hook "tflint kv" {
#     commands = ["validate", "plan"]
#     execute  = ["tflint"]
#   }
# }

inputs = {
  rg_name        = dependency.rg.outputs.rg_name
  key_vault_name = local.resource_name
  location       = local.region_vars.locals.location
  tags           = local.tags
  ip_rules       = local.ip_rules
  subnet_ids     = local.subnet_ids
  access_policies = [
    { object_id = local.env_vars.locals.sp_iac_object_id, secret_permissions = ["Get", "Set", "List", "Delete", "Purge"], key_permissions = ["Create", "List", "Get", "Update", "Purge", "Decrypt", "Encrypt", "Delete"] },
  ] # $REPLACE: Adapt to your object ids (check: https://docs.microsoft.com/de-de/azure/healthcare-apis/fhir/find-identity-object-ids)
  key_vault_keys = { sops-key = { key_type = "RSA", key_size = 2048, key_opts = ["decrypt", "encrypt"] } }
}