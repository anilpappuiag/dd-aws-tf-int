terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    datadog = {
      source  = "datadog/datadog"
      version = "~> 3.57"
    }
  }
}

provider "aws" {
  region = var.region
}

provider "datadog" {
  api_key = data.aws_secretsmanager_secret_version.dd_api_privatekey.secret_string
  app_key = data.aws_secretsmanager_secret_version.dd_app_privatekey.secret_string
  api_url = "https://api.datadoghq.eu/"
}
