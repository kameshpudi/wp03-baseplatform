locals {
}

remote_state {
  backend = "azurerm"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    resource_group_name  = "d-weu-infra-iac-tfstate-rg" # $REPLACE: Adapt to your resource group defined in _init
    storage_account_name = "dinfratfstate"              # $REPLACE: Adapt to your storage account defined in _init
    container_name       = "tfstate"
    key                  = "${path_relative_to_include()}/terraform.tfstate"
  }
}


# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  # $REPLACE: Please exchange subscription_id with yours
  contents = <<EOF
provider "azurerm" {
  features {}
}
EOF
}
