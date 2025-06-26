####################################################
# Checks: Runner Groups
####################################################

# Check and validate enterprise runner groups
# - Name is required
# - Type is required
# - Visibility is required
# - Visibility must be either "selected" or "all"
check "runner_groups_enterprise" {
  assert {
    condition = alltrue([
      for idx, group in var.github_actions_runner_groups :
      (can(group.type) && group.type == "enterprise") ? (
        can(group.name) &&
        can(group.type) &&
        (can(group.visibility) ? contains(["selected", "all"], group.visibility) : true)
      ) : true
    ])
    error_message = join("\n", [
      for idx, group in var.github_actions_runner_groups :
      (can(group.type) && group.type == "enterprise") && (
        !can(group.name) ||
        !can(group.type) ||
        !(can(group.visibility) ? contains(["selected", "all"], group.visibility) : true)
      ) ?
      format(
        "Invalid enterprise runner group: %s%s%s%s",
        (can(group.name) && group.name != null ? "'${group.name}'" : format("(index %d)", idx)),
        (!can(group.name) ? " [missing name]" : ""),
        (!can(group.type) ? " [missing type]" : ""),
        (!(can(group.visibility) ? contains(["selected", "all"], group.visibility) : true) ? " [invalid visibility]" : "")
      )
      : null
      if(can(group.type) && group.type == "enterprise") && (
        !can(group.name) ||
        !can(group.type) ||
        !(can(group.visibility) ? contains(["selected", "all"], group.visibility) : true)
      )
    ])
  }
}

# Check and validate enterprise runner group conditional fields
# - If workflow_whitelist.enabled is true, workflows must be a non-empty list
check "runner_groups_enterprise_conditional_fields" {
  assert {
    condition = alltrue([
      for idx, group in var.github_actions_runner_groups :
      (can(group.type) && group.type == "enterprise") ? (
        # If workflow_whitelist.enabled is true, workflows must be a non-empty list
        (
          !lookup(group.workflow_whitelist, "enabled", false) || (
            can(group.workflow_whitelist.workflows) &&
            group.workflow_whitelist.workflows != null &&
            length(group.workflow_whitelist.workflows) > 0
          )
        )
      ) : true
    ])
    error_message = join("\n", [
      for idx, group in var.github_actions_runner_groups :
      (can(group.type) && group.type == "enterprise") && (
        (lookup(group.workflow_whitelist, "enabled", false) && (
          !can(group.workflow_whitelist.workflows) ||
          group.workflow_whitelist.workflows == null ||
          length(group.workflow_whitelist.workflows) == 0
        ))
      ) ?
      format(
        "Invalid enterprise runner group: %s%s",
        (can(group.name) && group.name != null ? "'${group.name}'" : format("(index %d)", idx)),
        (lookup(group.workflow_whitelist, "enabled", false) && (
          !can(group.workflow_whitelist.workflows) ||
          group.workflow_whitelist.workflows == null ||
          length(group.workflow_whitelist.workflows) == 0
        )) ? " [workflow_whitelist.enabled is true but workflows is missing or empty]" : ""
      )
      : null
      if(can(group.type) && group.type == "enterprise") && (
        (lookup(group.workflow_whitelist, "enabled", false) && (
          !can(group.workflow_whitelist.workflows) ||
          group.workflow_whitelist.workflows == null ||
          length(group.workflow_whitelist.workflows) == 0
        ))
      )
    ])
  }
}

# Check and validate organization runner groups
# - Name is required
# - Type is required
# - Visibility must be either "private", "selected" or "all"
check "runner_groups_organization" {
  assert {
    condition = alltrue([
      for idx, group in var.github_actions_runner_groups :
      (can(group.type) && group.type == "organization") ? (
        can(group.name) &&
        can(group.type) &&
        (can(group.visibility) ? contains(["private", "selected", "all"], group.visibility) : true)
      ) : true
    ])
    error_message = join("\n", [
      for idx, group in var.github_actions_runner_groups :
      (can(group.type) && group.type == "organization") && (
        !can(group.name) ||
        !can(group.type) ||
        !(can(group.visibility) ? contains(["private", "selected", "all"], group.visibility) : true)
      ) ?
      format(
        "Invalid organization runner group: %s%s%s%s",
        (can(group.name) && group.name != null ? "'${group.name}'" : format("(index %d)", idx)),
        (!can(group.name) ? " [missing name]" : ""),
        (!can(group.type) ? " [missing type]" : ""),
        (!(can(group.visibility) ? contains(["private", "selected", "all"], group.visibility) : true) ? " [invalid visibility]" : "")
      )
      : null
      if(can(group.type) && group.type == "organization") && (
        !can(group.name) ||
        !can(group.type) ||
        !(can(group.visibility) ? contains(["private", "selected", "all"], group.visibility) : true)
      )
    ])
  }
}

# Check and validate organization runner group conditional fields
# - If visibility is 'selected' or 'private', allowed_repositories must be a non-empty list
# - If workflow_whitelist.enabled is true, workflows must be a non-empty list
check "runner_groups_organization_conditional_fields" {
  assert {
    condition = alltrue([
      for idx, group in var.github_actions_runner_groups :
      (can(group.type) && group.type == "organization") ? (
        # If visibility is 'selected' or 'private', allowed_repositories must be a non-empty list
        (!contains(["selected", "private"], lookup(group, "visibility", "all")) || (
          can(group.allowed_repositories) &&
          group.allowed_repositories != null &&
          length(group.allowed_repositories) > 0
        ))
        # If workflow_whitelist.enabled is true, workflows must be a non-empty list
        && (
          !lookup(group.workflow_whitelist, "enabled", false) || (
            can(group.workflow_whitelist.workflows) &&
            group.workflow_whitelist.workflows != null &&
            length(group.workflow_whitelist.workflows) > 0
          )
        )
      ) : true
    ])
    error_message = join("\n", [
      for idx, group in var.github_actions_runner_groups :
      (can(group.type) && group.type == "organization") && (
        (contains(["selected", "private"], lookup(group, "visibility", "all")) && (
          !can(group.allowed_repositories) ||
          group.allowed_repositories == null ||
          length(group.allowed_repositories) == 0
        ))
        ||
        (lookup(group.workflow_whitelist, "enabled", false) && (
          !can(group.workflow_whitelist.workflows) ||
          group.workflow_whitelist.workflows == null ||
          length(group.workflow_whitelist.workflows) == 0
        ))
      ) ?
      format(
        "Invalid organization runner group: %s%s%s",
        (can(group.name) && group.name != null ? "'${group.name}'" : format("(index %d)", idx)),
        (contains(["selected", "private"], lookup(group, "visibility", "all")) && (
          !can(group.allowed_repositories) ||
          group.allowed_repositories == null ||
          length(group.allowed_repositories) == 0
        )) ? " [visibility is 'selected' or 'private' but allowed_repositories is missing or empty]" : "",
        (lookup(group.workflow_whitelist, "enabled", false) && (
          !can(group.workflow_whitelist.workflows) ||
          group.workflow_whitelist.workflows == null ||
          length(group.workflow_whitelist.workflows) == 0
        )) ? " [workflow_whitelist.enabled is true but workflows is missing or empty]" : ""
      )
      : null
      if(can(group.type) && group.type == "organization") && (
        (contains(["selected", "private"], lookup(group, "visibility", "all")) && (
          !can(group.allowed_repositories) ||
          group.allowed_repositories == null ||
          length(group.allowed_repositories) == 0
        ))
        ||
        (lookup(group.workflow_whitelist, "enabled", false) && (
          !can(group.workflow_whitelist.workflows) ||
          group.workflow_whitelist.workflows == null ||
          length(group.workflow_whitelist.workflows) == 0
        ))
      )
    ])
  }
}
