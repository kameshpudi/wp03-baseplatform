locals {
  global_vars             = read_terragrunt_config(find_in_parent_folders("global-vars.hcl"))
  region_vars             = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  env_vars                = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  config_vars             = read_terragrunt_config("config.hcl")
  module_version          = local.env_vars.locals.module_version
  resource_tags           = { "arch" = "aks:${local.module_version}", "infra_region" = "${local.region_vars.locals.infra_region}", "env" = "${local.env_vars.locals.env}" }
  tags                    = merge(local.global_vars.locals.tags, local.resource_tags)
  resource_name           = replace("${local.env_vars.locals.resource_prefix}${local.global_vars.locals.resource_names.aks_name}${local.config_vars.locals.stage}", "-", "")
  source_base_url         = "${local.global_vars.locals.source_base_url}//aks"
  log_analytics_ws_name   = replace("${local.global_vars.locals.resource_names.log_analytics_ws_name}", "$PLACEHOLDER", "${local.region_vars.locals.infra_region}-${local.env_vars.locals.env}")
  mock_log_analytics_name = replace("${local.global_vars.locals.resource_names.log_analytics_ws_name}", "$PLACEHOLDER", "${local.region_vars.locals.infra_region}-${local.env_vars.locals.env}")
}

dependencies {
  paths = ["${get_terragrunt_dir()}//../rg-compute", "${get_terragrunt_dir()}//../log-analytics"]
}

dependency "rg" {
  config_path = "${get_terragrunt_dir()}//../rg-compute"
  # Mock outputs in case resource is not existing. This allows to run terragrunt run-all plan or validate on non-existing
  # resources. More information can be found here https://terragrunt.gruntwork.io/docs/features/execute-terraform-commands-on-multiple-modules-at-once/#dependencies-between-modules
  mock_outputs = {
    rg_name = "MOCK-aiqx-app-compute-rg"
  }
}

dependency "loga" {
  config_path = "${get_terragrunt_dir()}//../log-analytics"
  # Mock outputs in case resource is not existing. This allows to run terragrunt run-all plan or validate on non-existing
  # resources. More information can be found here https://terragrunt.gruntwork.io/docs/features/execute-terraform-commands-on-multiple-modules-at-once/#dependencies-between-modules
  mock_outputs = {
    log_analytics_ids = {
    "${local.mock_log_analytics_name}" = "/subscriptions/ca11ff22-5653-4822-b4dd-46c8da92f22/resourcegroups/dummy-rg/providers/microsoft.operationalinsights/workspaces/dummy-workspace" }
  }
}

terraform {
  # Execute validation via tflint after a terraform plan or terraform validation was run
  after_hook "tflint aks" {
    commands = ["validate", "plan"]
    execute  = ["tflint"]
  }
}

inputs = {
  rg_name                      = dependency.rg.outputs.rg_name
  aks_name                     = local.resource_name
  location                     = local.region_vars.locals.location
  dns_prefix                   = "aiqx-${local.config_vars.locals.stage}"
  node_resource_group_name     = "${dependency.rg.outputs.rg_name}-${local.config_vars.locals.stage}-nodes"
  kubernetes_version           = "1.24.3"
  orchestrator_version         = "1.24.3"
  node_pool_name               = "system"
  enable_auto_scaling          = true
  node_pool_count              = 3
  min_count                    = 3
  max_count                    = 4
  node_pool_vm_size            = "Standard_B2s"
  user_assigned_identity_id    = local.env_vars.locals.user_assigned_identity_id # $REPLACE: Adapt to your own MSI
  tags                         = local.tags
  enable_oms_agent             = true
  only_critical_addons_enabled = true
  log_analytics_workspace_id   = dependency.loga.outputs.log_analytics_ids["${local.log_analytics_ws_name}"]
  pod_cidr_range               = "10.244.0.0/16"
  subnet_id                    = ""
  additional_node_pools        = {}
}
