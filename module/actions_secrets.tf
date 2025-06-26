# Organization Secrets
resource "github_actions_organization_secret" "this" {
  for_each = {
    for secret in var.github_actions_secrets : secret.name => secret
    if secret.type == "organization"
  }

  secret_name = each.value.name

  encrypted_value = each.value.encrypted_value
  plaintext_value = each.value.plaintext_value

  visibility = lookup(each.value, "visibility", "private")

  # If visibility is "selected" then select_repository_ids is required.
  selected_repository_ids = (
    contains(["selected"], lookup(each.value, "visibility", "selected")) &&
    can(each.value.allowed_repositories) &&
    each.value.allowed_repositories != null
    ? compact([for repo in each.value.allowed_repositories : try(data.github_repository.this[repo].id, null)])
    : []
  )

  depends_on = [
    data.github_enterprise.this,
    data.github_organization.this
  ]

}

# Repository Secrets
resource "github_actions_secret" "this" {
  for_each = {
    for secret in var.github_actions_secrets : secret.name => secret
    if secret.type == "repository"
  }

  secret_name = each.value.name

  encrypted_value = each.value.encrypted_value
  plaintext_value = each.value.plaintext_value

  repository = each.value.repository

  depends_on = [
    data.github_enterprise.this,
    data.github_organization.this,
    data.github_repository.this
  ]
}

# Environment Secrets
resource "github_actions_environment_secret" "this" {
  for_each = {
    for secret in var.github_actions_secrets : secret.name => secret
    if secret.type == "environment"
  }

  secret_name = each.value.name

  encrypted_value = each.value.encrypted_value
  plaintext_value = each.value.plaintext_value

  repository  = each.value.repository
  environment = each.value.environment

  depends_on = [
    data.github_enterprise.this,
    data.github_organization.this,
    data.github_repository.this
  ]
}
