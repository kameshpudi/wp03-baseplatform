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