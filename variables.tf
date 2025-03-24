variable "api_key_secret_arn" {
  description = "The ARN of the secret containing the API key"
  type        = string
}

variable "app_key_secret_arn" {
  description = "The ARN of the secret containing the application key"
  type        = string
}

variable "region" {
  description = "The region to deploy the infrastructure to"
  type        = string
}

variable "accountId" {
  description = "The AWS account ID"
  type        = string
}
