####################################################
# Checks: Common Configuration Issues
####################################################

# Check organization name follows expected patterns
check "organization_name" {
  assert {
    condition = can(regex("^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?$", var.github_organization_name)) && length(var.github_organization_name) <= 39
    error_message = format(
      "Invalid organization name: '%s'\n  ✗ Organization names must be 1-39 characters, alphanumeric and hyphens only\n  ✗ Must start and end with alphanumeric characters\n  → Please check the organization name and ensure it follows GitHub naming conventions",
      var.github_organization_name
    )
  }
}

# Check repository names follow expected patterns
check "repository_names" {
  assert {
    condition = alltrue([
      for repo in local.all_referenced_repos :
      can(regex("^[a-zA-Z0-9._-]+$", repo)) && length(repo) <= 100
    ])
    error_message = join("\n", [
      for repo in local.all_referenced_repos :
      (!can(regex("^[a-zA-Z0-9._-]+$", repo)) || length(repo) > 100) ?
      format(
        "Invalid repository name: '%s'\n  ✗ Repository names must be 1-100 characters, alphanumeric, dots, underscores, and hyphens only\n  → Please check the repository name and ensure it follows GitHub naming conventions",
        repo
      ) : null
      if(!can(regex("^[a-zA-Z0-9._-]+$", repo)) || length(repo) > 100)
    ])
  }
}

# Validation check for missing organizations
resource "null_resource" "validate_organizations" {
  count = length(local.missing_orgs) > 0 ? 1 : 0

  triggers = {
    error_message = "ERROR: The following organizations are referenced in allowed_organizations but don't exist in github_organization_data: ${join(", ", local.missing_orgs)}. Available organizations: ${join(", ", keys(var.github_organization_data))}"
  }

  lifecycle {
    precondition {
      condition     = length(local.missing_orgs) == 0
      error_message = <<EOT
Organization name mismatch detected.

The following organizations are referenced in your runner groups but don't exist:

Referenced: [${join(", ", local.missing_orgs)}]

Available: [${join(", ", keys(var.github_organization_data))}]

Please check the organization names and ensure they exist in the github_organization_data map.
EOT
    }
  }
}
