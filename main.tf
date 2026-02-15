# =============================================================================
# terraform-tfe-workspace — Reusable TFC workspace with optional OIDC
# =============================================================================

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = ">= 0.50"
    }
  }
}

locals {
  # Auto-derive trigger patterns from working_directory when not explicitly set
  trigger_patterns = var.trigger_patterns != null ? var.trigger_patterns : (
    var.working_directory != "" ? ["${var.working_directory}/**/*.tf", "${var.working_directory}/**/*.tfvars"] : ["**/*.tf", "**/*.tfvars"]
  )
}

# =============================================================================
# Workspace
# =============================================================================

resource "tfe_workspace" "this" {
  name         = var.name
  organization = var.organization
  description  = var.description

  terraform_version = var.terraform_version
  working_directory = var.working_directory
  auto_apply        = var.auto_apply
  force_delete      = var.force_delete

  file_triggers_enabled = var.file_triggers_enabled
  trigger_patterns      = local.trigger_patterns
  speculative_enabled   = var.speculative_enabled

  tag_names = var.tag_names

  vcs_repo {
    identifier                 = var.vcs_repo
    github_app_installation_id = var.github_app_installation_id
    branch                     = var.branch
  }

  lifecycle {
    ignore_changes = [tag_names]
  }
}

resource "tfe_workspace_settings" "this" {
  workspace_id   = tfe_workspace.this.id
  execution_mode = var.execution_mode
}

# =============================================================================
# Workspace Variables
# =============================================================================

resource "tfe_variable" "workspace" {
  for_each = var.workspace_variables

  workspace_id = tfe_workspace.this.id
  key          = each.key
  value        = each.value.value
  sensitive    = each.value.sensitive
  category     = each.value.category
  description  = each.value.description
}

# =============================================================================
# Optional OIDC Dynamic Credentials
# =============================================================================

resource "tfe_variable_set" "oidc" {
  count = var.role_arn != null ? 1 : 0

  name         = "${var.name}-oidc-credentials"
  description  = "OIDC dynamic credentials for ${var.name} workspace"
  organization = var.organization
}

resource "tfe_workspace_variable_set" "oidc" {
  count = var.role_arn != null ? 1 : 0

  workspace_id    = tfe_workspace.this.id
  variable_set_id = tfe_variable_set.oidc[0].id
}

resource "tfe_variable" "oidc_auth" {
  count = var.role_arn != null ? 1 : 0

  variable_set_id = tfe_variable_set.oidc[0].id
  key             = "TFC_AWS_PROVIDER_AUTH"
  value           = "true"
  category        = "env"
  description     = "Enable OIDC dynamic credentials for AWS"
}

resource "tfe_variable" "oidc_role" {
  count = var.role_arn != null ? 1 : 0

  variable_set_id = tfe_variable_set.oidc[0].id
  key             = "TFC_AWS_RUN_ROLE_ARN"
  value           = var.role_arn
  category        = "env"
  description     = "IAM role ARN for OIDC authentication"
}
