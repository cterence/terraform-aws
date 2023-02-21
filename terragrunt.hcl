terragrunt_version_constraint = "~> 0.43.0"
terraform_version_constraint  = "~> 1.3.0"

locals {
  region  = "eu-west-3"
  profile = "terence.AdministratorAccess"
}

inputs = {
  region = local.region
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    provider "aws" {
      region  = "${local.region}"
      profile = "${local.profile}"
    }
    EOF
}

remote_state {
  backend = "local"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    path = "terraform.tfstate"
  }
}
