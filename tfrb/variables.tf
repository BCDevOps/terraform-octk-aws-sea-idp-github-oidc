variable "aws_region" {
  description = "AWS region for all resources."

  type    = string
  default = "ca-central-1"
}


variable "github_repos" {
  description = "GitHub repos for OIDC assumed role trust relationships"

  type = list(string)
  default = [
    "repo:{ORG_WITH_WORKLOAD_REPO}/{WORKLOAD_REPO}:ref:refs/heads/main"
  ]
}