locals {
  global_vars     = read_terragrunt_config(find_in_parent_folders("global-vars.hcl"))
  region_vars     = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  env_vars        = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  module_version  = local.env_vars.locals.module_version
  source_base_url = "${local.global_vars.locals.source_base_url}//private_dns_a_records"
}

terraform {
  # Execute validation via tflint after a terraform plan or terraform validation was run
  after_hook "tflint a-record" {
    commands = ["validate", "plan"]
    execute  = ["tflint"]
  }
}

inputs = {
  dns_a_record_map = { for k, v in local.global_vars.locals.private_dns_a_records : k => { dns_a_record_name = v.dns_a_record_name, records = [replace(v.records[0], "$PLACEHOLDER", v.dns_a_record_name == "rabbitmq-events" ? local.env_vars.locals.rabbit_mq_load_balancer_ip : v.dns_a_record_name == "sftp" ? local.env_vars.locals.sftp_load_balancer_ip : local.env_vars.locals.aks_load_balancer_ip)] } }
  dns_zone = {
    resource_group_name = local.env_vars.locals.private_dns_zone_rg
    name                = local.env_vars.locals.private_dns_zone_name
  }
}