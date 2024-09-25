locals {
  region_vars                = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  env                        = "development"
  env_prefix                 = "d"
  resource_prefix            = "${local.env_prefix}-${local.region_vars.locals.region_prefix}"
  module_version             = "v1.0.0"
  skip_deploy_aks_green      = false
  skip_deploy_aks_blue       = true
  subnet_id_aks_green        = "/subscriptions/e42f1bc7-b2b7-4d56-8ccf-7a3bd1549a00/resourceGroups/VNET-SPOKE-CAR-RG/providers/Microsoft.Network/virtualNetworks/VNET-SPOKE-CAR-100/subnets/aks-green"
  subnet_id_runner         = "/subscriptions/e42f1bc7-b2b7-4d56-8ccf-7a3bd1549a00/resourceGroups/VNET-SPOKE-CAR-RG/providers/Microsoft.Network/virtualNetworks/VNET-SPOKE-CAR-100/subnets/aks-green"
  
  subnet_ids                 = tolist([local.subnet_id_aks_green, local.subnet_id_runner])  
  sp_iac_object_id           = "552f7e98-3761-4fe3-bb55-01a5f0bfd35d" # not client id
  aks_load_balancer_ip       = "10.11.20.57"
  private_dns_zone_name      = "test-dev.azure.cloud.com"
  private_dns_zone_rg        = "group-dns"
  private_endpoint_rg        = "network"
  principal_id               = get_env("ARM_CLIENT_ID")
  principal_secret           = get_env("ARM_CLIENT_SECRET")
}