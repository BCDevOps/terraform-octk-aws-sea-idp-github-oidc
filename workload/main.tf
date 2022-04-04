terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.48.0"
    }
  }
  required_version = "~> 1.0"

  # Simple demo to show what the setup will look like for a
  # workload account deployment that leverages the AWS backend
  #
  # S3 bucket and DynamoDB specified here are provisioned by
  # Terraform configuration found in the tfrp folder
  backend "s3" {
    bucket = "tfrb-aws-poc-state-{ADD-AWS-ACCOUNT}-ca-central-1"
    key    = "tfrb-aws-poc/workload/terraform.tfstate"
    region = "ca-central-1"

    dynamodb_table = "tfrb-aws-poc-state-locks"
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name           = "GameScores"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "UserId"
  range_key      = "GameTitle"

  attribute {
    name = "UserId"
    type = "S"
  }

  attribute {
    name = "GameTitle"
    type = "S"
  }

  ttl {
    attribute_name = "TimeToExist"
    enabled        = false
  }

  tags = {
    Name        = "tfrb-aws-poc"
    Environment = "poc"
  }
}