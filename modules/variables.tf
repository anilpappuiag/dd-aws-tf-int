variable "api_key_secret_arn" {
  description = "The ARN of the secret containing the Datadog API key"
  type        = string
}

variable "region" {
  description = "The region to deploy the infrastructure to"
  default     = "eu-west-1"
  type        = string
}

variable "account_id" {
  description = "The AWS account ID to integrate with Datadog"
  type        = string
}
