locals {
  region_vars       = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  env               = "development"
  env_prefix        = "d"
  resource_prefix   = "${local.env_prefix}-${local.region_vars.locals.region_prefix}"
  module_version    = "v1.0.0"
  runners_subnet_id = "/subscriptions/e42f1bc7-b2b7-4d56-8ccf-7a3bd1549a00/resourceGroups/VNET-SPOKE-CAR-RG/providers/Microsoft.Network/virtualNetworks/VNET-SPOKE-CAR-100/subnets/aks-green"
  subnet_ids        = [local.runners_subnet_id]
}