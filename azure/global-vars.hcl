locals {

  app_name = "infra" # $REPLACE: Adapt to your needs. Changing this after resource creation forces a new resource to be created!

  source_base_url = "git::https://github.com/kameshpudi/tf-modules.git"
  
  tags = {
    "name"            = "${local.app_name}"
    "cost_costcenter" = "N/A" 
    "module_source"   = "https://github.com/kameshpudi/tf-modules"
  }

  resource_names = {
    tf_backend_name       = "${local.app_name}-iac-tfstate"
    rg_name_base          = "${local.app_name}-$PLACEHOLDER-rg" # "$PLACEHOLDER" will be replaced based upon purpose. Don't change this
    acr_name              = "${local.app_name}acr"
    aks_name              = "${local.app_name}aks"
    storage_account_name  = "${local.app_name}st"
  }

  networking = {    
  }

  aks = {
    node_pools = {
      infracore = {
        taints = ["core=true:NoSchedule"]
        labels = {
          core = true
        }
      }
    }
  }
}
