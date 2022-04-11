include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_path_to_repo_root()}//modules/lambda"
}

inputs = {
  source_dir = "../../environments/lambda/src/helloworld/"
  output_path = "helloworld.zip"

  handler       = "helloworld.lambda_handler"
}


//inputs = {
//  function_name = ""
//  handler = "lambda_function.lambda_handler"
//  runtime = ""
//  create_package = false
//  local_existing_package = ""
//
//  environment_variables = {
//    AWS_LAMBDA_EXEC_WRAPPER = "/opt/otel-instrument"
//  }
//
//  attach_policy_statements = true
//  policy_statements = {
//    s3 = {
//      effect = "Allow"
//      actions = [
//        "s3:ListAllMyBuckets"
//      ]
//      resources = [
//        "*"
//      ]
//    }
//  }
//}
