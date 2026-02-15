terraform {
  required_version = ">= 1.5.0"

  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = ">= 0.50"
    }
  }
}

provider "tfe" {}

# Basic VCS-driven workspace
module "workspace_myapp" {
  source  = "pomo-studio/workspace/tfe"
  version = "~> 1.0"

  name                       = "myapp"
  organization               = "MyOrg"
  vcs_repo                   = "my-org/my-app"
  github_app_installation_id = "ghain-abc123"
}

# Workspace with OIDC dynamic credentials
module "workspace_myapp_prod" {
  source  = "pomo-studio/workspace/tfe"
  version = "~> 1.0"

  name                       = "myapp-prod"
  organization               = "MyOrg"
  description                = "Production infrastructure"
  vcs_repo                   = "my-org/my-app"
  tag_names                  = ["production", "website"]
  role_arn                   = "arn:aws:iam::123456789012:role/terraform-cloud-myapp-prod"
  github_app_installation_id = "ghain-abc123"
}

# Workspace with custom variables
module "workspace_myapp_staging" {
  source  = "pomo-studio/workspace/tfe"
  version = "~> 1.0"

  name                       = "myapp-staging"
  organization               = "MyOrg"
  description                = "Staging infrastructure"
  vcs_repo                   = "my-org/my-app"
  role_arn                   = "arn:aws:iam::123456789012:role/terraform-cloud-myapp-staging"
  github_app_installation_id = "ghain-abc123"

  workspace_variables = {
    TFE_TOKEN = {
      value       = "your-team-token"
      sensitive   = true
      category    = "env"
      description = "TFC team token for cross-workspace state access"
    }
    aws_region = {
      value       = "us-west-2"
      category    = "terraform"
      description = "AWS region override for staging"
    }
  }
}
