# terraform-tfe-workspace

[![Terraform Validation](https://github.com/pomo-studio/terraform-tfe-workspace/actions/workflows/terraform.yml/badge.svg)](https://github.com/pomo-studio/terraform-tfe-workspace/actions/workflows/terraform.yml)
[![Terraform Registry](https://img.shields.io/badge/terraform-registry-844FBA?logo=terraform)](https://registry.terraform.io/modules/pomo-studio/workspace/tfe)

- [Changelog](CHANGELOG.md)

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

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_tfe"></a> [tfe](#requirement\_tfe) | >= 0.50, < 1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_tfe"></a> [tfe](#provider\_tfe) | 0.80.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [tfe_variable.oidc_auth](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable) | resource |
| [tfe_variable.oidc_role](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable) | resource |
| [tfe_variable.workspace](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable) | resource |
| [tfe_variable_set.oidc](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable_set) | resource |
| [tfe_workspace.this](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/workspace) | resource |
| [tfe_workspace_settings.this](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/workspace_settings) | resource |
| [tfe_workspace_variable_set.oidc](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/workspace_variable_set) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_auto_apply"></a> [auto\_apply](#input\_auto\_apply) | Auto-apply successful plans | `bool` | `false` | no |
| <a name="input_branch"></a> [branch](#input\_branch) | VCS branch to track | `string` | `"main"` | no |
| <a name="input_description"></a> [description](#input\_description) | Workspace description | `string` | `""` | no |
| <a name="input_execution_mode"></a> [execution\_mode](#input\_execution\_mode) | Workspace execution mode | `string` | `"remote"` | no |
| <a name="input_file_triggers_enabled"></a> [file\_triggers\_enabled](#input\_file\_triggers\_enabled) | Filter runs to trigger\_patterns paths only | `bool` | `true` | no |
| <a name="input_force_delete"></a> [force\_delete](#input\_force\_delete) | Allow workspace deletion even with managed resources | `bool` | `true` | no |
| <a name="input_github_app_installation_id"></a> [github\_app\_installation\_id](#input\_github\_app\_installation\_id) | GitHub App installation ID for VCS integration | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Workspace name | `string` | n/a | yes |
| <a name="input_organization"></a> [organization](#input\_organization) | TFC organization name | `string` | n/a | yes |
| <a name="input_role_arn"></a> [role\_arn](#input\_role\_arn) | IAM role ARN for OIDC dynamic credentials. When set, creates OIDC variable set. | `string` | `null` | no |
| <a name="input_speculative_enabled"></a> [speculative\_enabled](#input\_speculative\_enabled) | Enable speculative plans on PRs | `bool` | `true` | no |
| <a name="input_tag_names"></a> [tag\_names](#input\_tag\_names) | Workspace tags for organization | `list(string)` | `[]` | no |
| <a name="input_terraform_version"></a> [terraform\_version](#input\_terraform\_version) | Terraform version constraint | `string` | `">= 1.5.0"` | no |
| <a name="input_trigger_patterns"></a> [trigger\_patterns](#input\_trigger\_patterns) | File patterns that trigger runs. Auto-derived from working\_directory when null. | `list(string)` | `null` | no |
| <a name="input_vcs_repo"></a> [vcs\_repo](#input\_vcs\_repo) | GitHub repository identifier (e.g. pomo-studio/pomo-dev) | `string` | n/a | yes |
| <a name="input_working_directory"></a> [working\_directory](#input\_working\_directory) | Terraform working directory within the repo | `string` | `"infra"` | no |
| <a name="input_workspace_variables"></a> [workspace\_variables](#input\_workspace\_variables) | Workspace-level variables to create. Map key = variable name. | <pre>map(object({<br/>    value       = string<br/>    sensitive   = optional(bool, false)<br/>    category    = optional(string, "terraform")<br/>    description = optional(string, "")<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_variable_set_id"></a> [variable\_set\_id](#output\_variable\_set\_id) | OIDC variable set ID (null when role\_arn is not set) |
| <a name="output_workspace_id"></a> [workspace\_id](#output\_workspace\_id) | TFC workspace ID |
| <a name="output_workspace_name"></a> [workspace\_name](#output\_workspace\_name) | TFC workspace name |
| <a name="output_workspace_url"></a> [workspace\_url](#output\_workspace\_url) | Direct URL to the TFC workspace |
<!-- END_TF_DOCS -->

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

## License

MIT
