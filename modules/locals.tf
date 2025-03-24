locals {
  datadog_forwarder_lambda_arn = "arn:aws:lambda:${var.region}:${var.account_id}:function:datadog-forwarder"
}
