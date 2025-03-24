resource "aws_cloudformation_stack" "datadog_forwarder" {
  name         = "datadog-forwarder"
  capabilities = ["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM", "CAPABILITY_AUTO_EXPAND"]
  parameters = {
    DdApiKeySecretArn = var.api_key_secret_arn,
    DdSite            = "datadoghq.eu",
    FunctionName      = "datadog-forwarder"
  }
  template_url = "https://datadog-cloudformation-template.s3.amazonaws.com/aws/forwarder/latest.yaml"
}

resource "aws_cloudwatch_log_account_policy" "datadog_subscription_filter" {
  policy_name = "DatadogAccountSubscriptionPolicy"
  policy_type = "SUBSCRIPTION_FILTER_POLICY"
  policy_document = jsonencode(
    {
      DestinationArn = local.datadog_forwarder_lambda_arn
      FilterPattern  = ""
    }
  )
  selection_criteria = "LogGroupName NOT IN [\"/aws/lambda/datadog-forwarder\", \"/ec2/CloudWatchAgentLog/\", \"/ec2/var/log/cron\",\"/ec2/var/log/maillog\", \"/ec2/var/log/messages\",\"/ec2/var/log/secure\", \"/ec2/var/log/yum\"]"
  scope              = "ALL"
  depends_on         = [aws_cloudformation_stack.datadog_forwarder]
}
