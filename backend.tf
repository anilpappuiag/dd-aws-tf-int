terraform {
  backend "s3" {
    region = "eu-west-1"
    key    = "dd_aws_integration/terraform.tfstate"
  }
}
