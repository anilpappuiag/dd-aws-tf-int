terraform {
  required_version = ">= 1.3.0"
  required_providers {
    datadog = {
      source  = "datadog/datadog"
      version = "~> 3.57"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
