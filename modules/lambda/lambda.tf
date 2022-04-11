module "hello-lambda-function" {
  source  = "terraform-aws-modules/lambda/aws"
  version = ">= 2.24.0"

  architectures = compact([var.architecture])
  function_name = var.function_name
  handler       = var.handler
  runtime       = var.runtime

  create_package         = var.create_package
  local_existing_package = var.zip_file

  memory_size = var.memory_size
  timeout     = var.timeout

  layers = compact([
    var.collector_layer_arn
  ])
  tracing_mode = var.tracing_mode
  environment_variables = var.environment_variables

  attach_policy_statements = true
  policy_statements = var.policy_statements

  depends_on = [data.archive_file.zip_src]
}
