resource "datadog_integration_aws_account" "main" {
  aws_account_id = var.account_id
  aws_partition  = "aws"
  aws_regions {
    include_all = true
  }
  auth_config {
    aws_auth_config_role {
      role_name = "DatadogIntegrationRole"
    }
  }
  resources_config {
    cloud_security_posture_management_collection = false
    extended_collection                          = true
  }
  traces_config {
    xray_services {
    }
  }
  logs_config {
    lambda_forwarder {
      lambdas = [local.datadog_forwarder_lambda_arn]
      sources = [
        "apigw-access-logs",
        "apigw-execution-logs",
        "elb",
        "elbv2",
        "cloudfront",
        "lambda",
        "redshift",
        "s3",
        "waf",
        "states"
      ]
    }
  }
  metrics_config {
    automute_enabled          = true
    collect_cloudwatch_alarms = false
    collect_custom_metrics    = false
    enabled                   = true
    namespace_filters {
      exclude_only = ["AWS/SQS", "AWS/ElasticMapReduce"]
    }
    tag_filters {
      namespace = "AWS/Lambda"
      tags      = ["!ecp_deployer:ccoe", "!ecp_deployer:ba"]
    }
  }
}
