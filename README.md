# Datadog-AWS Integration with Terraform

## Introduction

This guide provides instructions for integrating AWS with Datadog using Terraform. The Terraform code sets up resources to enable Datadog to collect metrics, tags, and other telemetry for monitoring your AWS environment. Follow the steps below to configure and deploy the integration.

## Pre-Requisites

Before proceeding with the setup, ensure the following pre-requisites are met:

1. **AWS account with appropriate permissions**:
   - Create and manage IAM resources
   - Deploy CloudFormation stacks
   - Configure CloudWatch
   - Access AWS Secrets Manager
2. **API and App Key ARNs**:
   - **api_key_secret_arn** and **app_key_secret_arn** received from `agent-config.yaml` over email
3. **Terraform**:
   - Version 1.3.0 or later
4. **CI/CD Configuration** (if applicable):
   - Configure GitHub Workflows and Terraform Backends

   To automate the deployment process and manage Terraform state files, configure GitHub workflows and Terraform backends. This includes setting up DynamoDB tables and S3 buckets to store Terraform state files for the `dd_aws_integration` stage.

   - **GitHub Workflows**: Create a GitHub Actions workflow to automate the Terraform deployment process. This workflow should include steps to initialize Terraform, plan the changes, and apply the configuration.
   - **Terraform Backends**: Configure Terraform to use an S3 bucket for storing state files and a DynamoDB table for state locking and consistency.

   Example configuration for `backend.tf`:
   ```hcl
   terraform {
    backend "s3" {
      bucket         = "your-s3-bucket-name"
      key            = "path/to/terraform.tfstate"
      region         = "your-aws-region"
      dynamodb_table = "your-dynamodb-table-name"
    }
   }
   ```

   Ensure the S3 bucket and DynamoDB table are created and properly configured before running the Terraform commands.

## Setup

1. **Retrieve the API and App Key ARNs**:
   Retrieve the **api_key_secret_arn** and **app_key_secret_arn** from the configuration file `agent-config.yaml` that you have received via email from the observability portal. These ARNs are generated as part of the configuration process and are required for securely fetching the Datadog API and application keys from AWS Secrets Manager.

2. **Copy the Terraform Code**:
   Copy the *dd_aws_integration* [Terraform repository](https://github.com/BritishAirways-Ent/observability-portal/tree/main/terraform/dd_aws_integration) contents to your project repository or environment.

3. **Invoke the Local Terraform Module**:
   The copied *dd_aws_integration* stage should have a `main.tf` file of the root Terraform module from where you will need to invoke the child module using one of the following approaches that suits your existing configurations.

   ### Direct Parameter Approach
   Pass the parameters directly within the module block for a straightforward setup.
   ```hcl
   module "dd_aws_integration" {
     source              = "./modules"
     account_id          = "123456789012"
     api_key_secret_arn  = "arn:aws:secretsmanager:eu-west-1:123456789012:secret:datadog/api-key-XXXXXX"
     providers = {
       aws     = aws
       datadog = datadog
     }
   }
   ```

   ### Variables Approach
   Use variables for more flexibility and environment-specific configurations.
   ```hcl
   module "dd_aws_integration" {
     source              = "./modules"
     account_id          = var.accountId
     api_key_secret_arn  = var.api_key_secret_arn
     providers = {
       aws     = aws
       datadog = datadog
     }
   }
   ```

   Define the following variables in your relevant Terraform variable file:
   ```hcl
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
   ```

   Setting Variable Values:
   - You may set the values as defaults in the variable definitions above.
   - Alternatively, you can specify them in a `terraform.tfvars` file:
   ```hcl
   account_id          = "123456789012"
   region              = "eu-west-1"
   api_key_secret_arn  = "arn:aws:secretsmanager:eu-west-1:123456789012:secret:datadog/api-key-XXXXXX"
   app_key_secret_arn  = "arn:aws:secretsmanager:eu-west-1:123456789012:secret:datadog/app-key-XXXXXX"
   ```

4. **Provider Configuration**:
   You must configure the AWS and Datadog providers in your root module. Note that both API key and App key are needed for the Datadog provider configuration, even though only the API key is passed to the module:
   ```hcl
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

   # Both data sources are required for the Datadog provider
   data "aws_secretsmanager_secret_version" "dd_api_privatekey" {
     secret_id = var.api_key_secret_arn
   }

   data "aws_secretsmanager_secret_version" "dd_app_privatekey" {
     secret_id = var.app_key_secret_arn
   }
   ```

5. **Execute Terraform in Targeted AWS Account**:
   - Ensure you have **ECPAdmin/ECPDeveloper** privilege.
   - Run Terraform commands either through your CI/CD framework or manually via AWS CLI:
    ```sh
    terraform init
    terraform plan
    terraform apply
    ```

## Verification

Verify Integration in Datadog:
   - Upon successful Terraform execution, the targeted AWS account should appear in the Datadog console.
   ![alt text](images/datadog.jpeg)

## AWS Region Configuration

The default configuration uses AWS region **eu-west-1**.

If you wish to enable monitoring for another region, for example, region *eu-west-2*, you need to call the terraform module passing your region as an additional input.
```hcl
module "dd_aws_integration_secondary" {
  source              = "./modules"
  account_id          = var.accountId
  api_key_secret_arn  = var.api_key_secret_arn
  region              = "eu-west-2"
  providers = {
   aws     = aws
   datadog = datadog
  }
}
```

## Multi-Region Support

For multi-region deployment, set providers for each targeted region:

```hcl
provider "aws" {
  alias  = "eu-west-1"
  region = "eu-west-1"
}

provider "aws" {
  alias  = "eu-west-2"
  region = "eu-west-2"
}

module "dd_aws_integration_primary" {
  source              = "./modules"
  account_id          = var.accountId
  api_key_secret_arn  = var.api_key_secret_arn
  region              = "eu-west-1"
  providers = {
   aws     = aws.eu-west-1
   datadog = datadog
  }
}

module "dd_aws_integration_secondary" {
  source              = "./modules"
  account_id          = var.accountId
  api_key_secret_arn  = var.api_key_secret_arn
  region              = "eu-west-2"
  providers = {
   aws     = aws.eu-west-2
   datadog = datadog
  }
}
```

## Datadog Documentation Reference

For additional details, refer to the official Datadog documentation:
[Datadog Log Forwarding with Terraform](https://docs.datadoghq.com/logs/guide/forwarder/?tab=terraform#cloudformation-parameters)
[Datadog AWS Integration Setup with Terraform](https://docs.datadoghq.com/integrations/guide/aws-terraform-setup/)
