module "logging_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 4"

  trusted_role_services = [
    "transfer.amazonaws.com",
  ]

  create_role = true

  role_name         = "sftp_logging"
  role_requires_mfa = false

  custom_role_policy_arns = [
    aws_iam_policy.logging_access.arn
  ]
  number_of_custom_role_policy_arns = 1
}

resource "aws_iam_policy" "logging_access" {
  name        = "sftp_logging_access_policy"
  path        = "/"
  description = "SFTP server cloudwatch logging policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogStream",
          "logs:DescribeLogStreams",
          "logs:CreateLogGroup",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:log-group:/aws/transfer/*"
      },
    ]
  })
}
