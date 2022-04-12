variable "enable" {
  description = "Toggle to use or not use the SFTP server"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to the keys"
  type        = map(string)
}

variable "custom_domain_name" {
  description = "Custom domain name for the server"
  type        = string
}

variable "r53_zone_id" {
  description = "Route53 DNS Zone ID"
  type        = string
}

variable "dns_ttl" {
  description = "TTL for CNAME of custom domain name"
  type        = number
  default     = 900
}

variable "bucketname" {
  description = "The 'incoming' bucket for SFTP transfers"
  type        = string
}

variable "lambda_s3_bucket" {
  description = "S3 bucket to store lambda builds in"
  type        = string
}

variable "tracing_mode" {
  type        = string
  description = "Lambda function tracing mode"
  default     = "PassThrough"
}

variable "region" {
  description = "The aws region where this lambda is located"
  type        = string
  default = "ap-southeast-2"
}

locals {
  sdk_layer_arns_amd64 = {
    "ap-northeast-1" = "arn:aws:lambda:ap-northeast-1:901920570463:layer:aws-otel-python38-amd64-ver-1-9-1:2"
    "ap-northeast-2" = "arn:aws:lambda:ap-northeast-2:901920570463:layer:aws-otel-python38-amd64-ver-1-9-1:2"
    "ap-south-1"     = "arn:aws:lambda:ap-south-1:901920570463:layer:aws-otel-python38-amd64-ver-1-9-1:2"
    "ap-southeast-1" = "arn:aws:lambda:ap-southeast-1:901920570463:layer:aws-otel-python38-amd64-ver-1-9-1:2"
    "ap-southeast-2" = "arn:aws:lambda:ap-southeast-2:901920570463:layer:aws-otel-python38-amd64-ver-1-9-1:2"
    "ca-central-1"   = "arn:aws:lambda:ca-central-1:901920570463:layer:aws-otel-python38-amd64-ver-1-9-1:2"
    "eu-central-1"   = "arn:aws:lambda:eu-central-1:901920570463:layer:aws-otel-python38-amd64-ver-1-9-1:2"
    "eu-north-1"     = "arn:aws:lambda:eu-north-1:901920570463:layer:aws-otel-python38-amd64-ver-1-9-1:2"
    "eu-west-1"      = "arn:aws:lambda:eu-west-1:901920570463:layer:aws-otel-python38-amd64-ver-1-9-1:2"
    "eu-west-2"      = "arn:aws:lambda:eu-west-2:901920570463:layer:aws-otel-python38-amd64-ver-1-9-1:2"
    "eu-west-3"      = "arn:aws:lambda:eu-west-3:901920570463:layer:aws-otel-python38-amd64-ver-1-9-1:2"
    "sa-east-1"      = "arn:aws:lambda:sa-east-1:901920570463:layer:aws-otel-python38-amd64-ver-1-9-1:2"
    "us-east-1"      = "arn:aws:lambda:us-east-1:901920570463:layer:aws-otel-python38-amd64-ver-1-9-1:2"
    "us-east-2"      = "arn:aws:lambda:us-east-2:901920570463:layer:aws-otel-python38-amd64-ver-1-9-1:2"
    "us-west-1"      = "arn:aws:lambda:us-west-1:901920570463:layer:aws-otel-python38-amd64-ver-1-9-1:2"
    "us-west-2"      = "arn:aws:lambda:us-west-2:901920570463:layer:aws-otel-python38-amd64-ver-1-9-1:2"
  }

  adot_layer_arn = local.sdk_layer_arns_amd64[var.region]
}
