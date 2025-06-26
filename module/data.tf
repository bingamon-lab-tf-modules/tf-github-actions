# Lookup the GitHub Enterprise details.
data "github_enterprise" "this" {
  slug = var.github_enterprise_slug
}

# Lookup the GitHub Organization details
data "github_organization" "this" {
  name = var.github_organization_name
}

# Attempt to fetch all referenced repositories with error handling
data "github_repository" "this" {
  for_each = toset(local.all_referenced_repos)
  name     = each.value
}
