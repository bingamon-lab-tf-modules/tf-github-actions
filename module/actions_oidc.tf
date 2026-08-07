# OIDC Subject Claim Templates (Organization)
# Only 1 is allowed per organization.
resource "github_actions_organization_oidc_subject_claim_customization_template" "this" {
  for_each = {
    for template in var.github_actions_oidc_subject_claim_templates : "organization" => template
    if template.type == "organization"
  }

  include_claim_keys = each.value.include_claim_keys

  depends_on = [
    data.github_organization.this
  ]
}

# OIDC Subject Claim Templates (Repository)
# Only 1 is allowed per repository.
resource "github_actions_repository_oidc_subject_claim_customization_template" "this" {
  for_each = {
    for template in var.github_actions_oidc_subject_claim_templates : template.repository => template
    if template.type == "repository"
  }

  repository = each.value.repository

  use_default = lookup(each.value, "use_default", true)

  include_claim_keys = lookup(each.value, "use_default", true) == false ? each.value.include_claim_keys : null

  depends_on = [
    data.github_organization.this,
    data.github_repository.this
  ]
}