# Unit tests for terraform-tfe-workspace
#
# Requires Terraform >= 1.9.0
#   - mock_provider support (>= 1.7.0)
#   - cross-variable references in validation blocks (>= 1.9.0)
#
# NOTE: mock_provider generates synthetic IDs that may not pass TFE format
# validation in assert conditions. Tests here focus on resource counts, names,
# and configuration attributes — not IDs — to stay compatible with mock mode.

mock_provider "tfe" {
  # Provide valid ID formats so the TFE provider's validation doesn't
  # reject the synthetic values that mock_provider generates by default.

  mock_resource "tfe_workspace" {
    defaults = {
      id   = "ws-mock123"
      name = "mock-workspace"
    }
  }

  mock_resource "tfe_workspace_settings" {
    defaults = {
      id = "ws-settings-mock123"
    }
  }

  mock_resource "tfe_variable_set" {
    defaults = {
      id = "varset-mock123"
    }
  }

  mock_resource "tfe_workspace_variable_set" {
    defaults = {
      id = "ws-varset-mock123"
    }
  }

  mock_resource "tfe_variable" {
    defaults = {
      id = "var-mock123"
    }
  }
}

# Test 1: Basic workspace without OIDC
run "basic_workspace" {
  command = plan

  variables {
    name         = "test-workspace"
    organization = "test-org"
    vcs_repo     = "test-org/test-repo"
    description  = "Test workspace"
  }

  assert {
    condition     = tfe_workspace.this.name == "test-workspace"
    error_message = "Workspace name should be 'test-workspace'"
  }

  assert {
    condition     = tfe_workspace.this.organization == "test-org"
    error_message = "Organization should be 'test-org'"
  }

  assert {
    condition     = length(tfe_variable.workspace) == 0
    error_message = "No workspace variables should be created"
  }

  assert {
    condition     = length(tfe_variable_set.oidc) == 0
    error_message = "No OIDC variable set should be created without role_arn"
  }
}

# Test 2: Workspace with custom configuration
run "custom_workspace" {
  command = plan

  variables {
    name         = "custom-workspace"
    organization = "custom-org"
    vcs_repo     = "custom-org/custom-repo"
    description  = "Custom workspace with specific settings"
    branch       = "develop"
    working_directory = "terraform"
    auto_apply   = true
    force_delete = false
    speculative_enabled = false
    file_triggers_enabled = false
    execution_mode = "local"
    tag_names    = ["production", "backend"]
    
    workspace_variables = {
      TF_VAR_environment = {
        value       = "production"
        description = "Environment name"
        category    = "env"
      }
      region = {
        value       = "us-east-1"
        description = "AWS region"
        category    = "terraform"
      }
    }
  }

  assert {
    condition     = tfe_workspace.this.branch == "develop"
    error_message = "Branch should be 'develop'"
  }

  assert {
    condition     = tfe_workspace.this.working_directory == "terraform"
    error_message = "Working directory should be 'terraform'"
  }

  assert {
    condition     = tfe_workspace.this.auto_apply == true
    error_message = "Auto-apply should be enabled"
  }

  assert {
    condition     = length(tfe_variable.workspace) == 2
    error_message = "Should create 2 workspace variables"
  }

  assert {
    condition     = length(tfe_variable_set.oidc) == 0
    error_message = "No OIDC variable set should be created without role_arn"
  }
}

# Test 3: Workspace with OIDC configuration
run "workspace_with_oidc" {
  command = plan

  variables {
    name         = "oidc-workspace"
    organization = "oidc-org"
    vcs_repo     = "oidc-org/oidc-repo"
    role_arn     = "arn:aws:iam::123456789012:role/tfe-oidc-role"
    
    workspace_variables = {
      environment = {
        value = "staging"
      }
    }
  }

  assert {
    condition     = length(tfe_variable_set.oidc) == 1
    error_message = "Should create OIDC variable set when role_arn is set"
  }

  assert {
    condition     = length(tfe_workspace_variable_set.oidc) == 1
    error_message = "Should attach OIDC variable set to workspace"
  }

  assert {
    condition     = length(tfe_variable.oidc_auth) == 1
    error_message = "Should create OIDC auth variable"
  }

  assert {
    condition     = length(tfe_variable.oidc_role) == 1
    error_message = "Should create OIDC role variable"
  }

  assert {
    condition     = length(tfe_variable.workspace) == 1
    error_message = "Should create 1 workspace variable"
  }
}

# Test 4: Workspace with trigger patterns auto-derivation
run "trigger_patterns_auto_derivation" {
  command = plan

  variables {
    name         = "trigger-workspace"
    organization = "trigger-org"
    vcs_repo     = "trigger-org/trigger-repo"
    working_directory = "infra/modules"
  }

  # Trigger patterns should be auto-derived from working_directory
  # This is tested indirectly by checking the plan succeeds
  assert {
    condition     = tfe_workspace.this.working_directory == "infra/modules"
    error_message = "Working directory should be 'infra/modules'"
  }
}

# Test 5: Workspace with explicit trigger patterns
run "explicit_trigger_patterns" {
  command = plan

  variables {
    name         = "explicit-trigger-workspace"
    organization = "trigger-org"
    vcs_repo     = "trigger-org/trigger-repo"
    trigger_patterns = ["**/*.tf", "**/*.tfvars", "**/*.json"]
  }

  # With explicit trigger_patterns, they should be used as-is
  # This is tested indirectly by checking the plan succeeds
  assert {
    condition     = tfe_workspace.this.name == "explicit-trigger-workspace"
    error_message = "Workspace name should be 'explicit-trigger-workspace'"
  }
}

# Test 6: Variable validation - invalid category
run "invalid_variable_category" {
  command = plan

  variables {
    name         = "invalid-cat-workspace"
    organization = "test-org"
    vcs_repo     = "test-org/test-repo"
    
    workspace_variables = {
      test_var = {
        value     = "test"
        category  = "invalid"  # Should fail validation
      }
    }
  }

  expect_failures = [
    var.workspace_variables
  ]
}