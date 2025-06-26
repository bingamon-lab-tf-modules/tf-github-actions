####################################################
# Checks: OIDC
####################################################

# Check and validate OIDC subject claim templates
# - Type is required
check "oidc_subject_claim_templates" {
  assert {
    condition = alltrue([
      for idx, template in var.github_actions_oidc_subject_claim_templates :
      can(template.type) &&
      template.type != null
    ])
    error_message = join("\n", [
      for idx, template in var.github_actions_oidc_subject_claim_templates :
      (!can(template.type) || template.type == null) ?
      format("Invalid OIDC subject claim template (index %d): %s",
        idx,
        (!can(template.type) || template.type == null ? " [missing type]" : "")
      )
      : null
      if(!can(template.type) || template.type == null)
    ])
  }
}

# Check and validate OIDC subject claim templates - only one organization template allowed
# - Only one OIDC template is allowed per organization (and we have one organization per module)
check "oidc_subject_claim_templates_unique_organization" {
  assert {
    condition = length([
      for template in var.github_actions_oidc_subject_claim_templates : template
      if template.type == "organization"
    ]) <= 1
    error_message = "Multiple OIDC organization templates detected. Only one OIDC subject claim template of type 'organization' is allowed per module."
  }
}

# Check and validate OIDC subject claim templates - no duplicate repositories
# - Only one OIDC template is allowed per repository
check "oidc_subject_claim_templates_unique_repositories" {
  assert {
    condition = length([
      for template in var.github_actions_oidc_subject_claim_templates : template.repository
      if template.type == "repository" && can(template.repository) && template.repository != null
      ]) == length(distinct([
        for template in var.github_actions_oidc_subject_claim_templates : template.repository
        if template.type == "repository" && can(template.repository) && template.repository != null
    ]))
    error_message = format(
      "Duplicate OIDC repository templates detected. Only one OIDC subject claim template is allowed per repository.\nDuplicate repositories: %s",
      join(", ", [
        for name, templates in {
          for t in var.github_actions_oidc_subject_claim_templates : t.repository => t...
          if t.type == "repository" && can(t.repository) && t.repository != null
        } : name if length(templates) > 1
      ])
    )
  }
}

# Check and validate OIDC subject claim templates conditional fields
# - When type is organization: include_claim_keys are required
# - When type is repository: repository is required
# - When type is repository and use_default is true: include_claim_keys must NOT be present
# - When type is repository and use_default is false: include_claim_keys is required
check "oidc_subject_claim_templates_conditional_fields" {
  assert {
    condition = alltrue([
      for idx, template in var.github_actions_oidc_subject_claim_templates :
      (can(template.type) && template.type != null) ? (
        (template.type == "organization") ? (
          # Organization requires include_claim_keys
          can(template.include_claim_keys) && template.include_claim_keys != null && length(template.include_claim_keys) > 0
          ) : (template.type == "repository") ? (
          # Repository requires repository
          can(template.repository) && template.repository != null && template.repository != "" &&
          # Repository use_default logic
          (
            # If use_default is true (or default), include_claim_keys must NOT be present
            (lookup(template, "use_default", true) == true) ? (
              !(can(template.include_claim_keys) && template.include_claim_keys != null && length(template.include_claim_keys) > 0)
              ) : (
              # If use_default is false, include_claim_keys is required
              can(template.include_claim_keys) && template.include_claim_keys != null && length(template.include_claim_keys) > 0
            )
          )
        ) : true
      ) : true
    ])
    error_message = join("\n", [
      for idx, template in var.github_actions_oidc_subject_claim_templates :
      format(
        "Invalid OIDC subject claim template (index %d):%s%s%s%s",
        idx,
        (template.type == "organization" && (!can(template.include_claim_keys) || template.include_claim_keys == null || length(template.include_claim_keys) == 0)) ? " [type 'organization' requires include_claim_keys field]" : "",
        (template.type == "repository" && (!can(template.repository) || template.repository == null || template.repository == "")) ? " [type 'repository' requires repository field]" : "",
        (template.type == "repository" && lookup(template, "use_default", true) == true && (can(template.include_claim_keys) && template.include_claim_keys != null && length(template.include_claim_keys) > 0)) ? " [when use_default is true, include_claim_keys must not be present]" : "",
        (template.type == "repository" && lookup(template, "use_default", true) == false && (!can(template.include_claim_keys) || template.include_claim_keys == null || length(template.include_claim_keys) == 0)) ? " [when use_default is false, include_claim_keys is required]" : ""
      )
      if(can(template.type) && template.type != null) && (
        (template.type == "organization" && (
          (!can(template.include_claim_keys) || template.include_claim_keys == null || length(template.include_claim_keys) == 0)
        )) ||
        (template.type == "repository" && (
          (!can(template.repository) || template.repository == null || template.repository == "") ||
          # Repository use_default validation errors
          (
            (lookup(template, "use_default", true) == true && (can(template.include_claim_keys) && template.include_claim_keys != null && length(template.include_claim_keys) > 0)) ||
            (lookup(template, "use_default", true) == false && (!can(template.include_claim_keys) || template.include_claim_keys == null || length(template.include_claim_keys) == 0))
          )
        ))
      )
    ])
  }
}
