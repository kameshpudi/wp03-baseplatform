include "root" {
  path = find_in_parent_folders()
}

include "env" {
  path   = "${get_path_to_repo_root()}/azure/_envcommon/key-vault.hcl"
  expose = true
}

terraform {
  source = "${include.env.locals.source_base_url}?ref=${include.env.locals.module_version}"
}

inputs = {
  access_policies = [
    { object_id = include.env.locals.env_vars.locals.sp_iac_object_id, secret_permissions = ["Get", "Set", "List", "Delete", "Purge"], key_permissions = ["Create", "List", "Get", "Update", "Purge", "Decrypt", "Encrypt", "Delete"] }
  ]
  enable_network_rule_set = false  
}
