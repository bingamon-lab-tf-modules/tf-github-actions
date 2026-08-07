locals {
  # The provider constrains value / value_encrypted / encrypted_value /
  # plaintext_value with ExactlyOneOf, which rejects both "more than one" and
  # "none at all". Passing every field unconditionally therefore breaks every
  # secret that does not populate all of them, so exactly one argument is
  # emitted per secret and the others are left null for Terraform to omit.
  #
  # Precedence per secret:
  #   1. value or plaintext_value                      -> value
  #   2. value_encrypted or encrypted_value, + key_id  -> value_encrypted + key_id
  #   3. value_encrypted or encrypted_value, no key_id -> encrypted_value
  #
  # Case 3 keeps the deprecated encrypted_value because value_encrypted is
  # documented to pair with key_id and no caller supplies one yet. It remains
  # functional; a secret migrates to case 2 simply by gaining a key_id.
  actions_secret_values = {
    for secret in var.github_actions_secrets : secret.name => {
      plaintext = try(coalesce(secret.value, secret.plaintext_value), null)
      encrypted = try(coalesce(secret.value_encrypted, secret.encrypted_value), null)
      key_id    = secret.key_id
    }
  }

  actions_secret_arguments = {
    for name, secret in local.actions_secret_values : name => {
      value           = secret.plaintext
      value_encrypted = secret.plaintext == null && secret.key_id != null ? secret.encrypted : null
      key_id          = secret.plaintext == null && secret.key_id != null ? secret.key_id : null
      encrypted_value = secret.plaintext == null && secret.key_id == null ? secret.encrypted : null
    }
  }
}

# Organization Secrets
resource "github_actions_organization_secret" "this" {
  for_each = {
    for secret in var.github_actions_secrets : secret.name => secret
    if secret.type == "organization"
  }

  secret_name = each.value.name

  value           = local.actions_secret_arguments[each.key].value
  value_encrypted = local.actions_secret_arguments[each.key].value_encrypted
  key_id          = local.actions_secret_arguments[each.key].key_id
  encrypted_value = local.actions_secret_arguments[each.key].encrypted_value

  visibility = lookup(each.value, "visibility", "private")

  # Repository scoping lives in github_actions_organization_secret_repositories
  # below; selected_repository_ids on this resource is deprecated upstream.

  depends_on = [
    data.github_organization.this
  ]
}

# Organization Secret Repository Access
# Replaces the deprecated selected_repository_ids argument on
# github_actions_organization_secret. Only applies to secrets whose visibility
# is "selected"; the provider rejects a repository list for any other value.
resource "github_actions_organization_secret_repositories" "this" {
  for_each = {
    for secret in var.github_actions_secrets : secret.name => secret
    if secret.type == "organization" &&
    lookup(secret, "visibility", "private") == "selected" &&
    length(coalesce(secret.allowed_repositories, [])) > 0
  }

  # Referencing the secret keeps this resource ordered after it, which matters
  # because updating the secret itself resets the repository list server-side.
  secret_name = github_actions_organization_secret.this[each.key].secret_name

  selected_repository_ids = [
    for repo in each.value.allowed_repositories :
    data.github_repository.this[repo].repo_id
  ]

  depends_on = [
    data.github_repository.this
  ]
}

# Repository Secrets
resource "github_actions_secret" "this" {
  for_each = {
    for secret in var.github_actions_secrets : secret.name => secret
    if secret.type == "repository"
  }

  secret_name = each.value.name

  value           = local.actions_secret_arguments[each.key].value
  value_encrypted = local.actions_secret_arguments[each.key].value_encrypted
  key_id          = local.actions_secret_arguments[each.key].key_id
  encrypted_value = local.actions_secret_arguments[each.key].encrypted_value

  repository = each.value.repository

  depends_on = [
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

  value           = local.actions_secret_arguments[each.key].value
  value_encrypted = local.actions_secret_arguments[each.key].value_encrypted
  key_id          = local.actions_secret_arguments[each.key].key_id
  encrypted_value = local.actions_secret_arguments[each.key].encrypted_value

  repository  = each.value.repository
  environment = each.value.environment

  depends_on = [
    data.github_organization.this,
    data.github_repository.this
  ]
}
