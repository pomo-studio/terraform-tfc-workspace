# terraform-tfe-workspace

Reusable Terraform module for creating VCS-driven Terraform Cloud workspaces with optional OIDC dynamic credentials.

- VCS-driven workspace with GitHub App integration — push to main triggers a plan automatically
- OIDC dynamic credentials wired in one variable (`role_arn`) — no manual TFC variable set setup
- File trigger patterns auto-derived from `working_directory` — no boilerplate path config
- Workspace-scoped variables for secrets that don't belong in a shared variable set
- Pairs with `pomo-studio/oidc/aws` for a complete zero-static-credentials TFC setup

**Registry**: `pomo-studio/workspace/tfe`

## Usage

### Basic workspace

```hcl
module "workspace_myapp" {
  source  = "pomo-studio/workspace/tfe"
  version = "~> 1.1"

  name         = "myapp"
  organization = "MyOrg"
  vcs_repo     = "pomo-studio/myapp"
  github_app_installation_id = "ghain-abc123"
}
```

### With OIDC dynamic credentials

```hcl
module "workspace_myapp" {
  source  = "pomo-studio/workspace/tfe"
  version = "~> 1.1"

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

### With workspace variables

```hcl
module "workspace_myapp" {
  source  = "pomo-studio/workspace/tfe"
  version = "~> 1.1"

  name         = "myapp"
  organization = "MyOrg"
  vcs_repo     = "pomo-studio/myapp"
  role_arn     = module.oidc.role_arns["myapp"]
  github_app_installation_id = "ghain-abc123"

  workspace_variables = {
    TFE_TOKEN = {
      value       = var.tfe_token
      sensitive   = true
      category    = "env"
      description = "TFC team token for cross-workspace state access"
    }
    aws_region = {
      value    = "us-east-1"
      category = "terraform"
    }
  }
}
```

`workspace_variables` creates `tfe_variable` resources scoped directly to the workspace (not via a variable set). Sensitive values are marked hidden in the TFC UI and are never output.

## Variables

| Name | Type | Default | Required | Description |
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
| `workspace_variables` | `map(object)` | `{}` | no | Workspace-level variables. Each entry: `value`, `sensitive` (false), `category` ("terraform"\|"env"), `description` ("") |

## Outputs

| Output | Description |
|--------|-------------|
| `workspace_id` | TFC workspace ID |
| `workspace_name` | Workspace name |
| `workspace_url` | Direct URL to workspace |
| `variable_set_id` | OIDC variable set ID (null if no OIDC) |

## What it creates

Per module call:
- 1 `tfe_workspace` — VCS-driven, file-trigger enabled

Conditional:
- `tfe_variable_set` + 2 `tfe_variable` resources for OIDC credentials (`role_arn` set)
- N `tfe_variable` resources, one per entry in `workspace_variables`

## Design decisions

- **`trigger_patterns` auto-derives from `working_directory`** — when null, computes `["<dir>/**/*.tf", "<dir>/**/*.tfvars"]`. Pass explicitly to override.
- **`role_arn` as nullable toggle** — one variable serves as both feature flag and value. No separate `enable_oidc` boolean needed.
- **`lifecycle { ignore_changes = [tag_names] }`** — prevents TFC tag binding drift from causing plan changes.
- **Core workspace stays inline** — the workspace that manages OIDC infrastructure itself can't use this module (chicken/egg). This module is for site workspaces.
- **`workspace_variables` are workspace-scoped, not variable-set-scoped** — variables created via this input are attached directly to the workspace via `tfe_variable.workspace_id`, not to a shared variable set. Use this for workspace-specific values; use variable sets for values shared across multiple workspaces.
- **Sensitive values are never output** — `workspace_variables` values are not exposed in module outputs regardless of the `sensitive` flag.

## Examples

- [`examples/basic`](examples/basic/) — minimal VCS-driven workspace, no OIDC
- [`examples/complete`](examples/complete/) — OIDC dynamic credentials + workspace variables

## Requirements

| Tool | Version |
|------|---------|
| Terraform | `>= 1.5.0` |
| TFE provider | `>= 0.50` |

## License

MIT
