# Organization Variables
resource "github_actions_organization_variable" "this" {
  for_each = {
    for variable in var.github_actions_variables : variable.name => variable
    if variable.type == "organization"
  }

  variable_name = each.value.name
  value         = each.value.value

  visibility = lookup(each.value, "visibility", "private")

  # If visibility is "selected" then select_repository_ids is required.
  #
  # Use .repo_id, never .id: on data.github_repository the id attribute is the
  # repository NAME (the provider calls d.SetId(repoName)), while repo_id holds
  # the numeric database ID this set(number) argument requires.
  #
  # No compact()/try() wrapper: every name in allowed_repositories is collected
  # into local.all_referenced_repos and therefore always keyed in
  # data.github_repository.this, so a missing key is a genuine configuration
  # error that should surface rather than be silently dropped. compact() only
  # existed to strip the nulls try() injected, and it stringifies numbers.
  selected_repository_ids = (
    contains(["selected"], lookup(each.value, "visibility", "selected")) &&
    can(each.value.allowed_repositories) &&
    each.value.allowed_repositories != null
    ? [for repo in each.value.allowed_repositories : data.github_repository.this[repo].repo_id]
    : []
  )

  depends_on = [
    data.github_organization.this
  ]
}

# Repository Variables
resource "github_actions_variable" "this" {
  for_each = {
    for variable in var.github_actions_variables : variable.name => variable
    if variable.type == "repository"
  }

  variable_name = each.value.name
  value         = each.value.value

  repository = each.value.repository

  depends_on = [
    data.github_organization.this,
    data.github_repository.this
  ]
}

# Environment Variables
resource "github_actions_environment_variable" "this" {
  for_each = {
    for variable in var.github_actions_variables : variable.name => variable
    if variable.type == "environment"
  }

  variable_name = each.value.name
  value         = each.value.value

  repository  = each.value.repository
  environment = each.value.environment

  depends_on = [
    data.github_organization.this,
    data.github_repository.this
  ]
}
