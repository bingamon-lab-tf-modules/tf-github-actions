####################################################
# Checks: GitHub Actions Permissions Configuration
####################################################

# Check that allowed_actions_config is provided when allowed_actions is "selected"
check "permissions_allowed_actions_config" {
  assert {
    condition = (
      var.github_actions_permissions == null ? true :
      var.github_actions_permissions.allowed_actions == "selected" ?
      var.github_actions_permissions.allowed_actions_config != null : true
    )
    error_message = format(
      "GitHub Actions permissions validation failed:\n  ✗ allowed_actions_config is required when allowed_actions is set to 'selected'\n  → Current allowed_actions: '%s'\n  → Please provide allowed_actions_config with github_owned_allowed, verified_allowed, and patterns_allowed fields",
      var.github_actions_permissions != null ? var.github_actions_permissions.allowed_actions : "null"
    )
  }
}

# Check that enabled_repositories_config is provided when enabled_repositories is "selected"
check "permissions_enabled_repositories_config" {
  assert {
    condition = (
      var.github_actions_permissions == null ? true :
      var.github_actions_permissions.enabled_repositories == "selected" ?
      var.github_actions_permissions.enabled_repositories_config != null &&
      length(var.github_actions_permissions.enabled_repositories_config.repositories) > 0 : true
    )
    error_message = format(
      "GitHub Actions permissions validation failed:\n  ✗ enabled_repositories_config with repositories list is required when enabled_repositories is set to 'selected'\n  → Current enabled_repositories: '%s'\n  → Please provide enabled_repositories_config with a list of repository names",
      var.github_actions_permissions != null ? var.github_actions_permissions.enabled_repositories : "null"
    )
  }
}

# Check that repository names in permissions configuration follow GitHub naming conventions
check "permissions_repository_names" {
  assert {
    condition = (
      var.github_actions_permissions == null ? true :
      var.github_actions_permissions.enabled_repositories == "selected" &&
      var.github_actions_permissions.enabled_repositories_config != null ?
      alltrue([
        for repo in var.github_actions_permissions.enabled_repositories_config.repositories :
        can(regex("^[a-zA-Z0-9._-]+$", repo)) && length(repo) <= 100
      ]) : true
    )
    error_message = "GitHub Actions permissions repository name validation failed: Repository names must be 1-100 characters, alphanumeric, dots, underscores, and hyphens only. Please check all repository names in enabled_repositories_config."
  }
}
