module "transfer_access_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 4"

  trusted_role_services = [
    "transfer.amazonaws.com",
  ]

  create_role = true

  role_name         = "sftp_transfer_access"
  role_requires_mfa = false

  custom_role_policy_arns = [
    aws_iam_policy.transfer_access.arn
  ]
  number_of_custom_role_policy_arns = 1
}

resource "aws_iam_policy" "transfer_access" {
  name        = "transfer_access_policy"
  path        = "/"
  description = "SFTP server s3 transfer access policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:ListBucket"
        ]
        Effect = "Allow",
        Resource = [
          "arn:aws:s3:::${var.bucketname}"
        ]
      },
      {
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:GetObject",
          "s3:GetObjectAcl",
          "s3:GetObjectVersion",
          "s3:GetBucketLocation",
          "s3:List*"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::${var.bucketname}/*"
        ]
      },
      {
        Sid = "denyMkdir"
        Action = [
          "s3:PutObject"
        ]
        Effect = "Deny"
        Resource = [
          "arn:aws:s3:::${var.bucketname}/*/"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:GenerateDataKey*",
          "kms:Decrypt",
          "kms:Encrypt"
        ]
        Resource = "*"
      }
    ]
  })
}
