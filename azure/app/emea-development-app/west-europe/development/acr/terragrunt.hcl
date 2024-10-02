include "root" {
  path = find_in_parent_folders()
}

include "env" {
  path   = "${get_path_to_repo_root()}/azure/_envcommon/acr.hcl"
  expose = true
}

terraform {
  source = "${include.env.locals.source_base_url}?ref=${include.env.locals.module_version}"  
}

inputs = {
  ip_rules = concat(include.env.locals.ip_rules, ["198.61.40.120", "198.84.50.44","20.97.191.61"])
  enable_network_acls = false
}