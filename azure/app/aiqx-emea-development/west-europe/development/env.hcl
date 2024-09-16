locals {
  region_vars                = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  env                        = "development"
  env_prefix                 = "d"
  resource_prefix            = "${local.env_prefix}-${local.region_vars.locals.region_prefix}"
  module_version             = "v1.0.0"
  skip_deploy_aks_green      = false
  skip_deploy_aks_blue       = true
  subnet_id_aks_green        = "/subscriptions/1d7e357e-cf57-4eb5-b00e-193c473bee4a/resourceGroups/RG-VNET-SPOKE-AMS-791/providers/Microsoft.Network/virtualNetworks/VNET-SPOKE-AMS-791/subnets/aks-green"
  subnet_id_aks_blue         = "/subscriptions/1d7e357e-cf57-4eb5-b00e-193c473bee4a/resourceGroups/RG-VNET-SPOKE-AMS-791/providers/Microsoft.Network/virtualNetworks/VNET-SPOKE-AMS-791/subnets/aks-blue"
  subnet_id_runner           = "/subscriptions/1d7e357e-cf57-4eb5-b00e-193c473bee4a/resourceGroups/RG-VNET-SPOKE-AMS-791/providers/Microsoft.Network/virtualNetworks/VNET-SPOKE-AMS-791/subnets/paas-services"
  subnet_ids                 = tolist([local.subnet_id_aks_green, local.subnet_id_aks_blue, local.subnet_id_runner])
  mysql_vnet_rules           = { aks-green = { subnet_id = local.subnet_id_aks_green }, aks-blue = { subnet_id = local.subnet_id_aks_blue } }
  user_assigned_identity_id  = "/subscriptions/1d7e357e-cf57-4eb5-b00e-193c473bee4a/resourceGroups/d-weu-aiqx-msi-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/d-weu-aiqxmsi"
  sp_iac_object_id           = "889b257a-edc9-4877-a9d7-c4cd0065fc46"
  aks_load_balancer_ip       = "10.11.20.57"
}