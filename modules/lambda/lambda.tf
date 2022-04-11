module "hello-lambda-function" {
  source  = "terraform-aws-modules/lambda/aws"
  version = ">= 2.24.0"

  architectures = compact([var.architecture])
  function_name = var.name
  handler       = var.handler
  runtime       = var.runtime

  create_package         = false
  local_existing_package = var.output_path

  memory_size = 384
  timeout     = 20

//  layers = compact([
//    var.collector_layer_arn
//  ])

//  environment_variables = {
//    AWS_LAMBDA_EXEC_WRAPPER = "/opt/otel-instrument"
//  }

  tracing_mode = var.tracing_mode

  attach_policy_statements = true
  policy_statements = {
    s3 = {
      effect = "Allow"
      actions = [
        "s3:ListAllMyBuckets"
      ]
      resources = [
        "*"
      ]
    }
  }
  depends_on = [data.archive_file.zip_src]
}
