# terraform-octk-aws-sea-idp-github-oidc
Terraform module for S3 bucket backed state

## Readme notes from initial POC 
### Terraform Remote Backend - AWS Proof of Concept (tfrb-aws-poc)

This is an initial proof of concept for an alternative to Terraform Cloud. The idea is to deploy resources to supported Cloud Service Providers using GitHub actions rather than Terraform Cloud. The GitHub repository performing the deployment will be granted appropriate permission against the Cloud Service Provider via OIDC. Terraform state files will be stored in an S3 bucket with DynamoDB used for locking. The approach used here was developed before AWS S3 supported strong consistency. The general steps can be found here:

- [Configuring OpenID Connect in Amazon Web Services](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services)
- [Terraform Remote Backend using S3](https://www.terraform.io/language/settings/backends/s3)

#### Some Terminology
- Source Control: GitHub Repository
- Workflow: GitHub Actions using:
  - [actions/checkout@v2](https://github.com/marketplace/actions/checkout)
  - [aws-actions/configure-aws-credentials@v1](https://github.com/marketplace/actions/configure-aws-credentials-action-for-github-actions)
  - [hashicorp/setup-terraform@v1](https://github.com/marketplace/actions/hashicorp-setup-terraform)
- Terraform Remote Backend: AWS S3 with DynamoDB 
- Terraform Target: AWS


#### Sample GitHub Workflow
```yaml
---
name: "Terraform CI with S3 Backend"

on:
  push:
    branches: [main]

env:
  BUCKET_NAME : ${{ secrets.AWS_S3_BUCKET_NAME }}
  AWS_REGION : "ca-central-1"

# permission can be added at job level or workflow level
permissions:
  id-token: write
  contents: read    # This is required for actions/checkout@v2

defaults:
  run:
    working-directory: workload # WHere the Terraform config lives

jobs:
  TerraformCI:
    runs-on: ubuntu-latest

    steps:
      - name: Git clone the repository
        uses: actions/checkout@v2

      - name: configure aws credentials
        uses: aws-actions/configure-aws-credentials@v1
        with:
          role-to-assume: ${{ secrets.AWS_ROLE_TO_ASSUME }}
          role-session-name: GitHubOidcTestSession
          aws-region: ${{ env.AWS_REGION }}
      # Ref for Teffaform Versions: https://releases.hashicorp.com/terraform/
      - uses: hashicorp/setup-terraform@v1
        with:
          terraform_version: 1.0.11

      - name: Terraform Init
        id: init
        run: terraform init

      - name: Terraform Fmt
        id: fmt
        run: terraform fmt
        continue-on-error: true

      - name: Terraform Validate
        id: validate
        run: terraform validate

      - name: Terraform Plan
        id: plan
        run: terraform plan -no-color

      - name: Terraform apply
        id: apply
        run: terraform apply -auto-approve
```

#### References
1. [Amazon S3 Update – Strong Read-After-Write Consistency](https://aws.amazon.com/blogs/aws/amazon-s3-update-strong-read-after-write-consistency/)
2. [Deprecate S3 remote backend lock table with new strong consistency](https://github.com/hashicorp/terraform/issues/27070)
3. [Feature Request: Terraform state locking in AWS with S3 strong consistency, no DynamoDB](https://discuss.hashicorp.com/t/feature-request-terraform-state-locking-in-aws-with-s3-strong-consistency-no-dynamodb/18456)

