module "sftp_idp" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "3.1.0"

  count = var.enable ? 1 : 0

  function_name = "sftp_idp"
  description   = "Identity Provider for AWS Transfer Family SFTP service"
  handler       = "helloworld.lambda_handler"
  runtime       = "python3.9"
  memory_size   = 128
  timeout       = 5
  publish       = true
  store_on_s3   = true
  s3_bucket     = var.lambda_s3_bucket

  source_path = "${path.module}/idp_src"

  environment_variables = {
    bucketname         = var.bucketname
    transferaccessrole = module.transfer_access_role.iam_role_arn
//    log_level          = "error"
    log_level          = "debug"
    AWS_LAMBDA_EXEC_WRAPPER = "/opt/otel-instrument",
    OPENTELEMETRY_COLLECTOR_CONFIG_FILE = "/var/task/otel-collector-config.yaml"
  }

//  allowed_triggers = {
//    transfer = {
//      principal  = "transfer.amazonaws.com"
//      source_arn = aws_transfer_server.this[0].arn
//    }
//  }

  layers = compact([local.adot_layer_arn])
  tracing_mode = var.tracing_mode

//  attach_policy = true
//  policy        = "arn:aws:iam::aws:policy/AmazonCognitoReadOnly"

  attach_policy_statements = true
  policy_statements = {
    s3 = {
      effect = "Allow"
      actions = ["s3:ListAllMyBuckets"]
      resources = ["*"]
    },
    ec2 = {
      effect = "Allow"
      actions = ["ec2:DescribeInstances"]
      resources = ["*"]
    },
    xray = {
      effect = "Allow",
      actions = [
        "xray:PutTraceSegments",
        "xray:PutTelemetryRecords"
      ],
      resources: ["*"]
    }
  }

  tags = var.tags
}
