# terraform-tfc-workspace

Reusable Terraform module for creating VCS-driven Terraform Cloud workspaces with optional OIDC dynamic credentials.

## Usage

### Basic workspace

```hcl
module "workspace_myapp" {
  source       = "github.com/pomo-studio/terraform-tfc-workspace?ref=v1.0.0"
  name         = "myapp"
  organization = "MyOrg"
  vcs_repo     = "pomo-studio/myapp"
  github_app_installation_id = "ghain-abc123"
}
```

### With OIDC dynamic credentials

```hcl
module "workspace_myapp" {
  source       = "github.com/pomo-studio/terraform-tfc-workspace?ref=v1.0.0"
  name         = "myapp"
  organization = "MyOrg"
  description  = "My application infrastructure"
  vcs_repo     = "pomo-studio/myapp"
  tag_names    = ["website", "serverless-ssr"]
  role_arn     = module.oidc.role_arns["myapp"]
  github_app_installation_id = "ghain-abc123"
}
```

Setting `role_arn` creates a variable set with `TFC_AWS_PROVIDER_AUTH=true` and `TFC_AWS_RUN_ROLE_ARN` attached to the workspace. When `role_arn` is null (default), no OIDC resources are created.

## Variables

| Variable | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `name` | `string` | — | yes | Workspace name |
| `organization` | `string` | — | yes | TFC organization |
| `vcs_repo` | `string` | — | yes | GitHub repo (e.g. `pomo-studio/pomo-dev`) |
| `github_app_installation_id` | `string` | — | yes | GitHub App installation ID |
| `description` | `string` | `""` | no | Workspace description |
| `branch` | `string` | `"main"` | no | VCS branch |
| `working_directory` | `string` | `"infra"` | no | Terraform working directory |
| `terraform_version` | `string` | `">= 1.5.0"` | no | Version constraint |
| `auto_apply` | `bool` | `false` | no | Auto-apply successful plans |
| `force_delete` | `bool` | `true` | no | Allow deletion with resources |
| `speculative_enabled` | `bool` | `true` | no | Speculative plans on PRs |
| `file_triggers_enabled` | `bool` | `true` | no | Filter runs by path |
| `trigger_patterns` | `list(string)` | `null` | no | File trigger patterns (auto-derived from working_directory when null) |
| `execution_mode` | `string` | `"remote"` | no | Execution mode |
| `tag_names` | `list(string)` | `[]` | no | Workspace tags |
| `role_arn` | `string` | `null` | no | IAM role ARN — creates OIDC var set when set |

## Outputs

| Output | Description |
|--------|-------------|
| `workspace_id` | TFC workspace ID |
| `workspace_name` | Workspace name |
| `workspace_url` | Direct URL to workspace |
| `variable_set_id` | OIDC variable set ID (null if no OIDC) |

## Design decisions

- **`trigger_patterns` auto-derives from `working_directory`** — when null, computes `["<dir>/**/*.tf", "<dir>/**/*.tfvars"]`. Pass explicitly to override.
- **`role_arn` as nullable toggle** — one variable serves as both feature flag and value. No separate `enable_oidc` boolean needed.
- **`lifecycle { ignore_changes = [tag_names] }`** — prevents TFC tag binding drift from causing plan changes.
- **Core workspace stays inline** — the workspace that manages OIDC infrastructure itself can't use this module (chicken/egg). This module is for site workspaces.

## Requirements

- Terraform >= 1.5.0
- hashicorp/tfe provider >= 0.50
