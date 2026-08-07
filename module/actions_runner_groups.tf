# Enterprise Runner Groups
resource "github_enterprise_actions_runner_group" "this" {
  for_each = {
    for runner_group in var.github_actions_runner_groups : runner_group.name => runner_group
    if runner_group.type == "enterprise"
  }

  # The slug of the enterprise where the runner group will be created.
  enterprise_slug = var.github_enterprise_slug

  # The name of the runner group. Must be unique within the enterprise.
  name = each.value.name

  # Whether public repositories are allowed to be used with this runner group.
  allows_public_repositories = lookup(each.value, "allows_public_repositories", false)

  # If visibility is "selected", then we need to provide organization_ids. Can be 'all', 'selected'.
  visibility = lookup(each.value, "visibility", "all")

  # If visibility is "selected", provide the organization_ids from passed data
  # Add validation to ensure organization exists in the data map
  selected_organization_ids = (
    lookup(each.value, "visibility", "all") == "selected" && length(lookup(each.value, "allowed_organizations", [])) > 0
    ? [
      for org in lookup(each.value, "allowed_organizations", []) :
      tonumber(var.github_organization_data[org].database_id)
      if contains(keys(var.github_organization_data), org)
    ]
    : null
  )

  # Workflow whitelist
  restricted_to_workflows = lookup(each.value, "workflow_whitelist", {}).enabled != null ? lookup(each.value, "workflow_whitelist", {}).enabled : false
  selected_workflows      = lookup(each.value, "workflow_whitelist", {}).workflows != null ? lookup(each.value, "workflow_whitelist", {}).workflows : null
}

# Organization Runner Groups
resource "github_actions_runner_group" "this" {
  for_each = {
    for runner_group in var.github_actions_runner_groups : runner_group.name => runner_group
    if runner_group.type == "organization"
  }

  # The name of the runner group. Must be unique within the organization.
  name = each.value.name

  # Whether public repositories are allowed to be used with this runner group.
  allows_public_repositories = lookup(each.value, "allows_public_repositories", false)

  # If visibility is "selected", then we need to provide repository_ids. Can be 'all', 'selected', or 'private'.
  visibility = lookup(each.value, "visibility", "all")

  # If visibility is "selected" or "private", provide repository_ids from lookups.
  #
  # Use .repo_id, never .id: on data.github_repository the id attribute is the
  # repository NAME (the provider calls d.SetId(repoName)), while repo_id holds
  # the numeric database ID this argument requires. repo_id is already a number,
  # so no tonumber() conversion is needed.
  selected_repository_ids = (
    contains(["selected", "private"], lookup(each.value, "visibility", "all")) && length(each.value.allowed_repositories) > 0
    ? [for repo in each.value.allowed_repositories : data.github_repository.this[repo].repo_id]
    : []
  )

  # Workflow whitelist
  restricted_to_workflows = lookup(each.value.workflow_whitelist, "enabled", false)
  selected_workflows      = lookup(each.value.workflow_whitelist, "workflows", null)
}