resource "aws_transfer_server" "this" {
  count                  = var.enable ? 1 : 0
  identity_provider_type = "AWS_LAMBDA"
  protocols              = ["SFTP"]
  function               = module.sftp_idp[0].lambda_function_arn
  logging_role           = module.logging_role.iam_role_arn
  security_policy_name   = "TransferSecurityPolicy-2020-06"
  tags                   = merge(var.tags, { "Hostname" = var.custom_domain_name })
}

resource "aws_route53_record" "this" {
  count           = var.enable && length(var.custom_domain_name) > 0 && length(var.r53_zone_id) > 0 ? 1 : 0
  name            = var.custom_domain_name
  zone_id         = var.r53_zone_id
  type            = "CNAME"
  ttl             = var.dns_ttl
  allow_overwrite = true
  records = [
    aws_transfer_server.this[0].endpoint
  ]
}

output "fqdn" {
  description = "Fully Qualified Domain Name of the SFTP transfer server"
  value       = aws_route53_record.this[0].fqdn
}
