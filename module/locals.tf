# Collect all referenced repositories from configuration
locals {
  # Organizations

  # Extract all organization names referenced in allowed_organizations
  referenced_orgs = toset(flatten([
    for runner_group in var.github_actions_runner_groups :
    lookup(runner_group, "allowed_organizations", [])
    if runner_group.type == "enterprise" && lookup(runner_group, "visibility", "all") == "selected"
  ]))

  # Find organizations that are referenced but don't exist in the data map
  missing_orgs = [
    for org in local.referenced_orgs : org
    if !contains(keys(var.github_organization_data), org)
  ]

  # Repositories

  # Extract all repository names referenced in allowed_repositories
  all_referenced_repos = distinct(flatten([
    # Repositories from allowed_repositories (enterprise runner groups)
    [for group in var.github_actions_runner_groups : (
      can(group.allowed_repositories) &&
      group.allowed_repositories != null ?
      group.allowed_repositories : []
    )],
    # Repositories from repository field (actions variables)
    [for variable in var.github_actions_variables : (
      can(variable.repository) && variable.repository != null ? [variable.repository] : []
    )],
    # Repositories from allowed_repositories field (actions variables)
    [for variable in var.github_actions_variables : (
      can(variable.allowed_repositories) && variable.allowed_repositories != null ? variable.allowed_repositories : []
    )],
    # Repositories from repository field (actions secrets)
    [for secret in var.github_actions_secrets : (
      can(secret.repository) && secret.repository != null ? [secret.repository] : []
    )],
    # Repositories from allowed_repositories field (actions secrets)
    [for secret in var.github_actions_secrets : (
      can(secret.allowed_repositories) && secret.allowed_repositories != null ? secret.allowed_repositories : []
    )],
    # Repositories from repository field (OIDC subject claim templates)
    [for template in var.github_actions_oidc_subject_claim_templates : (
      can(template.repository) && template.repository != null ? [template.repository] : []
    )],
    # Repositories from actions permissions (enabled repositories config)
    var.github_actions_permissions != null ? (
      var.github_actions_permissions.enabled_repositories == "selected" &&
      var.github_actions_permissions.enabled_repositories_config != null ?
      var.github_actions_permissions.enabled_repositories_config.repositories : []
    ) : []
  ]))
}
