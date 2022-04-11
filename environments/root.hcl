locals {
  aws_region = "ap-southeast-2"
  aws_azs    = ["${local.aws_region}a", "${local.aws_region}b", "${local.aws_region}c"]
}

inputs = {
  region             = local.aws_region
  azs                = local.aws_azs
  availability_zones = local.aws_azs
}

terraform {
  extra_arguments "common_vars" {
    commands = get_terraform_commands_that_need_vars()
    optional_var_files = [
      find_in_parent_folders("regional.tfvars"),
    ]
  }
}

remote_state {
  backend = "s3"
  generate = {
    path      = "_backend.tf"
    if_exists = "overwrite"
  }
  config = {
    encrypt        = true
    region         = local.aws_region
    key            = "${path_relative_to_include()}/terraform.tfstate"
    bucket         = "tfstate-${get_aws_account_id()}.identitii.com"
    dynamodb_table = "tfstate-${get_aws_account_id()}"
  }
}

generate "provider" {
  path      = "_provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = var.aws_region
  allowed_account_ids = ["204532658794"]
}
variable "aws_region" {
  description = "AWS region to create infrastructure in"
  type        = string
}
EOF
}
