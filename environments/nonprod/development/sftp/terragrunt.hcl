include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "${get_path_to_repo_root()}//modules/sftp"
}

dependencies {
  paths = ["../dns", "../storage/s3"]
}

dependency "dns" {
  config_path = "../dns"
}

dependency "s3" {
  config_path = "../storage/s3"
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders())
  zone_name = "platform.dev.identitii.com"
}

inputs = {
  enable = true

  custom_domain_name = "sftp.${local.zone_name}"
  region             =  "ap-southeast-2"
  r53_zone_id        = dependency.dns.outputs.zone_ids[local.zone_name]
  bucketname         = dependency.s3.outputs.buckets["incoming"]["s3_bucket_id"]
  lambda_s3_bucket   = dependency.s3.outputs.buckets["lambdas"]["s3_bucket_id"]
  tracing_mode       = "Active"

  tags = {
    "Managed By" = "Terragrunt"
  }
}
