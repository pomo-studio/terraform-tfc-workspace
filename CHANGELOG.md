# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-02-21

### Added
- Initial release of Terraform Cloud Workspace module
- Creates VCS-driven workspaces with GitHub App integration
- Supports OIDC dynamic credentials for AWS, Azure, GCP
- Configurable workspace settings and variables
- Comprehensive input validation

### Features
- **VCS integration**: GitHub App installation for repository access
- **Dynamic credentials**: OIDC provider configuration for cloud platforms
- **Flexible configuration**: Customizable workspace settings
- **Production-ready**: Input validation prevents misconfiguration
- **Multi-cloud support**: AWS, Azure, GCP OIDC configurations

### Usage Example
```hcl
module "workspace_myapp" {
  source  = "pomo-studio/workspace/tfe"
  version = "~> 1.0"

  name         = "myapp"
  organization = "MyOrg"
  vcs_repo     = "pomo-studio/myapp"
  github_app_installation_id = "ghain-abc123"

  # Optional OIDC configuration for AWS
  oidc_provider = {
    provider_url    = "https://app.terraform.io"
    client_id_list  = ["aws.workload.identity"]
    thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da2b0ab7280"]
  }

  # Workspace variables
  terraform_variables = {
    environment = "production"
    region      = "us-east-1"
  }

  # Environment variables (sensitive)
  environment_variables = {
    AWS_ACCESS_KEY_ID = "AKIA..."
  }
}
```

### Breaking Changes
This is the initial release. No breaking changes from previous versions.

[1.0.0]: https://github.com/pomo-studio/terraform-tfe-workspace/releases/tag/v1.0.0