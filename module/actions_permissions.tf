# Create GitHub Actions organization permissions if configuration is provided
resource "github_actions_organization_permissions" "this" {
  count = var.github_actions_permissions != null ? 1 : 0

  # Required: enabled_repositories policy
  enabled_repositories = var.github_actions_permissions.enabled_repositories

  # Optional: allowed_actions policy (defaults to "all")
  allowed_actions = var.github_actions_permissions.allowed_actions

  # Optional: require SHA pinning for actions and reusable workflows.
  # Defaults to false, so the module asserts SHA pinning is off unless a caller
  # deliberately turns it on.
  sha_pinning_required = var.github_actions_permissions.sha_pinning_required

  # Dynamic allowed_actions_config block
  dynamic "allowed_actions_config" {
    for_each = (
      var.github_actions_permissions.allowed_actions == "selected" &&
      var.github_actions_permissions.allowed_actions_config != null
    ) ? [var.github_actions_permissions.allowed_actions_config] : []

    content {
      github_owned_allowed = allowed_actions_config.value.github_owned_allowed
      verified_allowed     = allowed_actions_config.value.verified_allowed
      patterns_allowed     = allowed_actions_config.value.patterns_allowed
    }
  }

  # Dynamic enabled_repositories_config block
  dynamic "enabled_repositories_config" {
    for_each = (
      var.github_actions_permissions.enabled_repositories == "selected" &&
      var.github_actions_permissions.enabled_repositories_config != null
    ) ? [var.github_actions_permissions.enabled_repositories_config] : []

    content {
      # Convert repository names to repository IDs using data lookups
      repository_ids = [
        for repo_name in enabled_repositories_config.value.repositories :
        data.github_repository.this[repo_name].repo_id
      ]
    }
  }
}
