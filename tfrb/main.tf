terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.48.0"
    }
  }
  required_version = "~> 1.0"

  # If using AWS based solution to store the backend infrastructure
  # update this section after deploying the backend infrastructure
  #  backend "s3" {
  #    bucket = "tfrb-aws-poc-{ADD-AWS-ACCOUNT}-ca-central-1"
  #    key    = "tfrb-aws-poc/s3/terraform.tfstate"
  #    region = "ca-central-1"
  #  }

}

provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_s3_bucket" "tfrb_aws_poc_state" {
  bucket        = "tfrb-aws-poc-state-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}"
  acl           = "private"
  force_destroy = false

  # Prevent accidental deletion of this bucket
  lifecycle {
    prevent_destroy = true
  }

  # Enable versioning so state file versioning is easily available
  versioning {
    enabled = true
  }
}

resource "aws_dynamodb_table" "tfrb_aws_poc_state_locks" {
  name         = "tfrb-aws-poc-state-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}

# References:
# https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc_verify-thumbprint.html
# https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create_for-idp_oidc.html
# https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services
#
resource "aws_iam_openid_connect_provider" "tfrb_aws_poc_state_github_oidc" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com",
  ]

  # REf: https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc_verify-thumbprint.html
  thumbprint_list = [
    "15E29108718111E59B3DAD31954647E3C344A231",
    "6938FD4D98BAB03FAADB97B34396831E3780AEA1"
  ]
}

# TODO: Revise role name to include ci
resource "aws_iam_role" "tfrb_aws_poc_state_role" {
  name = "tfrb-aws-poc-state-role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    "Statement" = [
      {
        "Effect" = "Allow",
        "Action" = "sts:AssumeRoleWithWebIdentity",
        "Principal" = {
          "Federated" = aws_iam_openid_connect_provider.tfrb_aws_poc_state_github_oidc.arn
        },
        "Condition" = {
          "ForAllValues:StringEquals" = {
            "token.actions.githubusercontent.com:aud" = [
              "sts.amazonaws.com"
            ],
            "token.actions.githubusercontent.com:sub" = var.github_repos
          }
        }
      }
    ]
  })

  tags = {
    tag-key = "tag-value"
  }
}

resource "aws_iam_policy" "tfrb_aws_poc_state_policy" {
  name        = "tfrb_aws_poc_state_policy"
  description = "Manages permissions assumed by GitHub OIDC assumed IAM role"

  policy = jsonencode({
    Version = "2012-10-17"
    "Statement" : [
      {
        "Sid" : "ListObjectsInBucket",
        "Effect" : "Allow",
        "Action" : ["s3:ListBucket"],
        "Resource" : [aws_s3_bucket.tfrb_aws_poc_state.arn]
      },
      {
        "Sid" : "AllObjectActions",
        "Effect" : "Allow",
        "Action" : "s3:*Object",
        "Resource" : ["${aws_s3_bucket.tfrb_aws_poc_state.arn}/*"]
      },
      {
        "Sid" : "AllowStateLockActions",
        "Effect" : "Allow",
        "Action" : [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ],
        "Resource" : aws_dynamodb_table.tfrb_aws_poc_state_locks.arn
      },
      {
        "Sid" : "AllowDynamoDBActions",
        "Effect" : "Allow",
        "Action" : [
          "dynamodb:*"
        ],
        "Resource" : ["*"]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "tfrb_aws_poc_state_role_attach" {
  role       = aws_iam_role.tfrb_aws_poc_state_role.name
  policy_arn = aws_iam_policy.tfrb_aws_poc_state_policy.arn
}
