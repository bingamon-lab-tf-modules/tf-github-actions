####################################################
# GitHub Actions Organization Permissions Outputs
####################################################

output "github_actions_organization_permissions" {
  description = "GitHub Actions organization permissions configuration"
  value = var.github_actions_permissions != null ? {
    id                   = github_actions_organization_permissions.this[0].id
    allowed_actions      = github_actions_organization_permissions.this[0].allowed_actions
    enabled_repositories = github_actions_organization_permissions.this[0].enabled_repositories
  } : null
}
