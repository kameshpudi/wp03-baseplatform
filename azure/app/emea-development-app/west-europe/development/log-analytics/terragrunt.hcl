include "root" {
  path = find_in_parent_folders()
}

include "env" {
  path   = "${get_path_to_repo_root()}/azure/_envcommon/log-analytics-ws.hcl"
  expose = true
}

terraform {
  source = "${include.env.locals.source_base_url}?ref=${include.env.locals.module_version}"
}

inputs = {
  workspaces = { "${include.env.locals.log_analytics_ws_name}" : { "sku" : "PerGB2018", "retention_in_days" : 30, internet_ingestion_enabled = true, internet_query_enabled = true } }
}
