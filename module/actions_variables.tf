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
    data.github_enterprise.this,
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
    data.github_enterprise.this,
    data.github_organization.this,
    data.github_repository.this
  ]
}
