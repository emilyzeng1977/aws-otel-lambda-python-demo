include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_path_to_repo_root()}//modules/lambda"
}

inputs = {
  # Utils
  source_dir = "../../environments/lambda/src/helloworld/"
  zip_file = "helloworld.zip"

  # Lambda
  function_name = "hello-python"
  handler       = "helloworld.lambda_handler"
  runtime = "python3.8"

  collector_layer_arn  = "arn:aws:lambda:ap-southeast-2:901920570463:layer:aws-otel-python38-amd64-ver-1-9-1:2"
  tracing_mode = "Active"
  environment_variables = {
    AWS_LAMBDA_EXEC_WRAPPER = "/opt/otel-instrument",
    OPENTELEMETRY_COLLECTOR_CONFIG_FILE = "/var/task/collector.yaml"
  }

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
}
