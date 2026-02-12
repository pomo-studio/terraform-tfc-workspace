# =============================================================================
# Variables
# =============================================================================

variable "name" {
  description = "Workspace name"
  type        = string
}

variable "organization" {
  description = "TFC organization name"
  type        = string
}

variable "vcs_repo" {
  description = "GitHub repository identifier (e.g. pomo-studio/pomo-dev)"
  type        = string
}

variable "github_app_installation_id" {
  description = "GitHub App installation ID for VCS integration"
  type        = string
}

variable "description" {
  description = "Workspace description"
  type        = string
  default     = ""
}

variable "branch" {
  description = "VCS branch to track"
  type        = string
  default     = "main"
}

variable "working_directory" {
  description = "Terraform working directory within the repo"
  type        = string
  default     = "infra"
}

variable "terraform_version" {
  description = "Terraform version constraint"
  type        = string
  default     = ">= 1.5.0"
}

variable "auto_apply" {
  description = "Auto-apply successful plans"
  type        = bool
  default     = false
}

variable "force_delete" {
  description = "Allow workspace deletion even with managed resources"
  type        = bool
  default     = true
}

variable "speculative_enabled" {
  description = "Enable speculative plans on PRs"
  type        = bool
  default     = true
}

variable "file_triggers_enabled" {
  description = "Filter runs to trigger_patterns paths only"
  type        = bool
  default     = true
}

variable "trigger_patterns" {
  description = "File patterns that trigger runs. Auto-derived from working_directory when null."
  type        = list(string)
  default     = null
}

variable "execution_mode" {
  description = "Workspace execution mode"
  type        = string
  default     = "remote"
}

variable "tag_names" {
  description = "Workspace tags for organization"
  type        = list(string)
  default     = []
}

variable "role_arn" {
  description = "IAM role ARN for OIDC dynamic credentials. When set, creates OIDC variable set."
  type        = string
  default     = null
}
