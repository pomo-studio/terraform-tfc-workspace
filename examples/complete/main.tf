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

# =============================================================================
# Basic Workspace Examples
# =============================================================================

# Minimal workspace with VCS integration
module "basic_workspace" {
  source = "../.."

  name                       = "basic-app"
  organization               = "my-org"
  vcs_repo                   = "my-org/basic-app"
  github_app_installation_id = "ghain-abc123"
}

# Workspace with custom settings
module "custom_workspace" {
  source = "../.."

  name                       = "custom-app"
  organization               = "my-org"
  vcs_repo                   = "my-org/custom-app"
  github_app_installation_id = "ghain-abc123"
  description                = "Custom workspace with specific settings"
  branch                     = "develop"
  working_directory          = "terraform/infra"
  auto_apply                 = true
  force_delete               = false
  speculative_enabled        = false
  file_triggers_enabled      = false
  execution_mode             = "local"
  tag_names                  = ["backend", "api"]
}

# =============================================================================
# Workspace with OIDC Dynamic Credentials
# =============================================================================

# Production workspace with OIDC
module "production_workspace" {
  source = "../.."

  name                       = "production-app"
  organization               = "my-org"
  vcs_repo                   = "my-org/production-app"
  github_app_installation_id = "ghain-abc123"
  description                = "Production infrastructure with OIDC credentials"
  tag_names                  = ["production", "critical"]
  role_arn                   = "arn:aws:iam::123456789012:role/tfc-production-role"

  workspace_variables = {
    TF_VAR_environment = {
      value       = "production"
      description = "Environment name"
      category    = "env"
    }
    TF_VAR_aws_region = {
      value       = "us-east-1"
      description = "AWS region for production"
      category    = "terraform"
    }
    TF_VAR_database_url = {
      value       = "postgresql://prod-db.example.com:5432/app"
      sensitive   = true
      description = "Production database connection string"
      category    = "env"
    }
  }
}

# Staging workspace with OIDC
module "staging_workspace" {
  source = "../.."

  name                       = "staging-app"
  organization               = "my-org"
  vcs_repo                   = "my-org/staging-app"
  github_app_installation_id = "ghain-abc123"
  description                = "Staging environment with OIDC credentials"
  tag_names                  = ["staging", "testing"]
  role_arn                   = "arn:aws:iam::123456789012:role/tfc-staging-role"

  workspace_variables = {
    TF_VAR_environment = {
      value       = "staging"
      description = "Environment name"
      category    = "env"
    }
    TF_VAR_aws_region = {
      value       = "us-west-2"
      description = "AWS region for staging"
      category    = "terraform"
    }
    TF_VAR_instance_type = {
      value       = "t3.small"
      description = "EC2 instance type for staging"
      category    = "terraform"
    }
  }
}

# =============================================================================
# Workspace with Advanced Configuration
# =============================================================================

# Workspace with explicit trigger patterns
module "advanced_workspace" {
  source = "../.."

  name                       = "advanced-app"
  organization               = "my-org"
  vcs_repo                   = "my-org/advanced-app"
  github_app_installation_id = "ghain-abc123"
  description                = "Advanced workspace with custom trigger patterns"
  working_directory          = "infrastructure"
  trigger_patterns           = ["infrastructure/**/*.tf", "infrastructure/**/*.tfvars", "infrastructure/**/*.json"]

  workspace_variables = {
    TFC_CONFIGURATION_VERSION_GIT_BRANCH = {
      value       = "feature/new-infra"
      description = "Git branch for configuration version"
      category    = "env"
    }
    TF_VAR_project_name = {
      value       = "advanced-project"
      description = "Project name for resource tagging"
      category    = "terraform"
    }
  }
}

# =============================================================================
# Multi-environment Workspace Pattern
# =============================================================================

# Development workspace (no OIDC, manual apply)
module "development_workspace" {
  source = "../.."

  name                       = "development-app"
  organization               = "my-org"
  vcs_repo                   = "my-org/development-app"
  github_app_installation_id = "ghain-abc123"
  description                = "Development environment - manual apply only"
  auto_apply                 = false
  tag_names                  = ["development", "experimental"]

  workspace_variables = {
    TF_VAR_environment = {
      value       = "development"
      description = "Environment name"
      category    = "env"
    }
    TF_VAR_debug_mode = {
      value       = "true"
      description = "Enable debug logging"
      category    = "terraform"
    }
  }
}

# =============================================================================
# Outputs
# =============================================================================

output "workspace_ids" {
  description = "IDs of created workspaces"
  value = {
    basic       = module.basic_workspace.workspace_id
    custom      = module.custom_workspace.workspace_id
    production  = module.production_workspace.workspace_id
    staging     = module.staging_workspace.workspace_id
    advanced    = module.advanced_workspace.workspace_id
    development = module.development_workspace.workspace_id
  }
}

output "oidc_variable_set_ids" {
  description = "IDs of OIDC variable sets (when role_arn is set)"
  value = {
    production = module.production_workspace.oidc_variable_set_id
    staging    = module.staging_workspace.oidc_variable_set_id
  }
}

output "workspace_urls" {
  description = "URLs to access workspaces in Terraform Cloud"
  value = {
    basic       = "https://app.terraform.io/app/my-org/workspaces/basic-app"
    custom      = "https://app.terraform.io/app/my-org/workspaces/custom-app"
    production  = "https://app.terraform.io/app/my-org/workspaces/production-app"
    staging     = "https://app.terraform.io/app/my-org/workspaces/staging-app"
    advanced    = "https://app.terraform.io/app/my-org/workspaces/advanced-app"
    development = "https://app.terraform.io/app/my-org/workspaces/development-app"
  }
}