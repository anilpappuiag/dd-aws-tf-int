output "lamda_arn" {
  description = "The ARN of the Datadog forwarder lambda"
  value       = aws_cloudformation_stack.datadog_forwarder.outputs["DatadogForwarderArn"]
}
