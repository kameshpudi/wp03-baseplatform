generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  # $REPLACE: Please exchange subscription_id with yours
  contents = <<EOF
provider "azurerm" {
  features {}
  subscription_id = "e42f1bc7-b2b7-4d56-8ccf-7a3bd1549a00"
  tenant_id       = "0e25fa75-cd3c-4d4f-b97b-fdfdfddd691a"
}
EOF
}