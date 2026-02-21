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