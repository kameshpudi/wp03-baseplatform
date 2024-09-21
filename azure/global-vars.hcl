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
    log_analytics_ws_name = "${local.app_name}-log-analytics-ws-$PLACEHOLDER" # "$PLACEHOLDER" will be replaced based upon purpose. Don't change this
    storage_account_name  = "${local.app_name}st"
    private_endpoint_name = "${local.app_name}-pvte"
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
  private_dns_a_records = {
    services = {
      dns_a_record_name = "services"
      records           = ["$PLACEHOLDER"]
    },
    argocd = {
      dns_a_record_name = "argocd"
      records           = ["$PLACEHOLDER"]
    },
    monitoring = {
      dns_a_record_name = "monitoring"
      records           = ["$PLACEHOLDER"]
    },
    rabbitmq = {
      dns_a_record_name = "rabbitmq"
      records           = ["$PLACEHOLDER"]
    },
    rabbitmq-events = {
      dns_a_record_name = "rabbitmq-events"
      records           = ["$PLACEHOLDER"]
    },
    pushgateway = {
      dns_a_record_name = "pushgateway"
      records           = ["$PLACEHOLDER"]
    },
    prometheus = {
      dns_a_record_name = "prometheus"
      records           = ["$PLACEHOLDER"]
    },
    sftp = {
      dns_a_record_name = "sftp"
      records           = ["$PLACEHOLDER"]
    }
  }
}
