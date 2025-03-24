module "dd_aws_integration" {
  source             = "./modules"
  account_id         = var.accountId
  api_key_secret_arn = var.api_key_secret_arn
  providers = {
    aws     = aws
    datadog = datadog
  }
}

data "aws_secretsmanager_secret_version" "dd_api_privatekey" {
  secret_id = var.api_key_secret_arn
}

data "aws_secretsmanager_secret_version" "dd_app_privatekey" {
  secret_id = var.app_key_secret_arn
}
