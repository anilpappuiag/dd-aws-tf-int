# Introduction
This Terraform module enables seamless integration between your AWS accounts and Datadog for comprehensive monitoring and observability.

The module creates necessary AWS resources including:
- IAM roles and policies for Datadog access
- Cloudformation stack to vend Forwarder Lambda for log collections
- CloudWatch log collection
- AWS service metrics collection

# Prerequisites

1. AWS account with appropriate permissions - IAM roles and permissions to
    - Create and manage IAM resources
    - Deploy CloudFormation stacks
    - Configure CloudWatch
    - Access AWS Secrets Manager
2. Datadog API and App keys stored in AWS Secrets Manager
3. Terraform 1.3.0 or later

# Usage
To leverage the integration, populate this code as per the instructions below.
1. Retrieve the **api_key_secret_arn** and **app_key_secret_arn** from the configuration file `agent-config.yaml` that you have received via email sent by the observability portal. These ARNs are generated as part of the configuration process and are required for securely fetching the Datadog API and application keys from AWS Secrets Manager.

2. Add the module to your Terraform configuration following any of the approaches below based on your specfic requirements

##  Direct Parameter Approach
```
module "dd_aws_integration" {
  source              = "git::https://github.com/BritishAirways-Ent/observability-dd-integration.git?ref=v.1.x.x"
  account_id           = "123456789012"
  api_key_secret_arn  = "arn:aws:secretsmanager:eu-west-1:123456789012:secret:datadog/api-key-XXXXXX"
  app_key_secret_arn  = "arn:aws:secretsmanager:eu-west-1:123456789012:secret:datadog/app-key-XXXXXX"
}
```

## Variables Approach
Use variables for more flexibility and environment-specific configurations. Please refer the sample configuration present as under the test folder in this repository.
(https://github.com/BritishAirways-Ent/observability-dd-integration/tree/main/test)

```
  module "dd_aws_integration" {
  source = "git://https://github.com/BritishAirways-Ent/observability-dd-integration.git?ref=v.1.x.x" 
  account_id          = var.account_id
  api_key_secret_arn = var.api_key_arn
  app_key_secret_arn = var.app_key_arn
}
```

# Module Input Variables

The following variables to be configured when using this module:

| Variable Name | Data Type | Required | Default Value | Description |
|---------------|-----------|----------|--------------|-------------|
| `account_id` | string | Yes | - | The AWS Account ID to integrate with Datadog. |
| `api_key_secret_arn` | string | Yes | - | ARN of the AWS Secrets Manager secret containing your Datadog API key. Format: `arn:aws:secretsmanager:region:account-id:secret:secret-name` |
| `app_key_secret_arn` | string | Yes | - | ARN of the AWS Secrets Manager secret containing your Datadog App key. Format: `arn:aws:secretsmanager:region:account-id:secret:secret-name` |
| `region` | string | No | `"eu-west-1"` | AWS region where resources will be deployed. For multi-region setup, use multiple module instances with different providers as described in the section below under Multi-Region Support section. |


# Deployment
Execute terraform code in the targeted AWS account with ECPAdmin/ECPDeveloper privilege. This step can be performed via appropriate CI/CD framework or make a AWS CLI login to account and execute the following terraform commands.
    - terraform init
    - terraform plan
    - terraform apply

# Validation
Upon successful terraform execution the targeted AWS account should start appearing in datadog console.
![alt text](images/datadog.jpeg)

# AWS Region

Current code base is an example of capturing logs from AWS region eu-west-1.

If you wish to send logs from other region for example region *eu-west-2*, you need to call the terraform module passing your region as an additional input.

```
module "dd_aws_integration_secondary" {
  source              = "git::https://github.com/BritishAirways-Ent/observability-dd-integration.git?ref=v.1.x.x"
  account_id           = var.account_id
  api_key_secret_arn  = var.api_key_arn
  app_key_secret_arn  = var.app_key_arn
  region              = "eu-west-2"
}
```

# Multi-Region Support

For multi-region deployment, set providers for each targeted region:

```
provider "aws" {
  alias  = "eu-west-1"
  region = "eu-west-1"
}

provider "aws" {
  alias  = "eu-west-2"
  region = "eu-west-2" 
}

module "dd_aws_integration_primary" {
  source              = "git::https://github.com/BritishAirways-Ent/observability-dd-integration.git?ref=v.1.x.x"
  providers = {
    aws = aws.eu-west-1
  }
  account_id           = var.account_id
  api_key_secret_arn  = var.api_key_arn
  app_key_secret_arn  = var.app_key_arn
}

module "dd_aws_integration_secondary" {
  source              = "git::https://github.com/BritishAirways-Ent/observability-dd-integration.git?ref=v.1.x.x"
  providers = {
    aws = aws.eu-west-2
  }
  account_id           = var.account_id
  api_key_secret_arn  = var.api_key_arn
  app_key_secret_arn  = var.app_key_arn
  region              = "eu-west-2"
}
```

# Datadog document reference

https://docs.datadoghq.com/logs/guide/forwarder/?tab=terraform#cloudformation-parameters
