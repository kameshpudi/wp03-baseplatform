include "root" {
  path = find_in_parent_folders()
}

include "env" {
  path   = "${get_path_to_repo_root()}/azure/_envcommon/aks.hcl"
  expose = true
}

terraform {
  source = "${include.env.locals.source_base_url}?ref=${include.env.locals.module_version}"
}

inputs = {
  kubernetes_version   = "1.29.7"
  orchestrator_version = "1.29.7"
  node_pool_vm_size    = "Standard_DS2_v2"
  node_pool_count      = 1
  min_count            = 1
  max_count            = 3
  subnet_id            = include.env.locals.env_vars.locals.subnet_id_aks_green
  additional_node_pools = {
    "infracore" = {
      node_count          = 1
      vm_size             = "Standard_DS2_v2"
      taints              = include.env.locals.global_vars.locals.aks.node_pools.infracore.taints
      labels              = include.env.locals.global_vars.locals.aks.node_pools.infracore.labels
      enable_auto_scaling = true
      node_min_count      = 1
      node_max_count      = 4
      os_disk_size_gb     = 64
    }
  }
  private_cluster_enabled     = true
  identity_type               = "service_principal"
  principal_id                = include.env.locals.env_vars.locals.principal_id
  principal_secret            = include.env.locals.env_vars.locals.principal_secret
}

# Need for blue green deployment of an AKS
skip = include.env.locals.env_vars.locals.skip_deploy_aks_green