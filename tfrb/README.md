<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.48.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 3.48.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_dynamodb_table.tfrb_aws_poc_state_locks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table) | resource |
| [aws_iam_openid_connect_provider.tfrb_aws_poc_state_github_oidc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) | resource |
| [aws_iam_policy.tfrb_aws_poc_state_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.tfrb_aws_poc_state_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.tfrb_aws_poc_state_role_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_s3_bucket.tfrb_aws_poc_state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region for all resources. | `string` | `"ca-central-1"` | no |
| <a name="input_github_repos"></a> [github\_repos](#input\_github\_repos) | GitHub repos for OIDC assumed role trust relationships | `list(string)` | <pre>[<br>  "repo:{ORG_WITH_WORKLOAD_REPO}/{WORKLOAD_REPO}:ref:refs/heads/main"<br>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_state_files_bucket_name"></a> [state\_files\_bucket\_name](#output\_state\_files\_bucket\_name) | Name of the S3 bucket used to store Terraform state files. |
| <a name="output_state_locks_table_name"></a> [state\_locks\_table\_name](#output\_state\_locks\_table\_name) | Name of the DynamoDB table used to store Terraform state locks. |
| <a name="output_tfrb_aws_poc_state_github_oidc_arn"></a> [tfrb\_aws\_poc\_state\_github\_oidc\_arn](#output\_tfrb\_aws\_poc\_state\_github\_oidc\_arn) | n/a |
<!-- END_TF_DOCS -->