output "state_files_bucket_name" {
  description = "Name of the S3 bucket used to store Terraform state files."

  value = aws_s3_bucket.tfrb_aws_poc_state.id
}


output "state_locks_table_name" {
  description = "Name of the DynamoDB table used to store Terraform state locks."

  value = aws_dynamodb_table.tfrb_aws_poc_state_locks.name
}

output "tfrb_aws_poc_state_github_oidc_arn" {
  value = aws_iam_openid_connect_provider.tfrb_aws_poc_state_github_oidc.arn
}
