####################################################
# Checks: Actions Variables
####################################################

# Check and validate actions variables
# - Name is required
# - Value is required
# - Type is required
check "actions_variables" {
  assert {
    condition = alltrue([
      for idx, variable in var.github_actions_variables :
      can(variable.name) &&
      variable.name != null &&
      can(variable.value) &&
      variable.value != null &&
      can(variable.type) &&
      variable.type != null
    ])
    error_message = join("\n", [
      for idx, variable in var.github_actions_variables :
      (!can(variable.name) || variable.name == null || !can(variable.value) || variable.value == null || !can(variable.type) || variable.type == null) ?
      format("Invalid actions variable: %s%s%s", variable.name, (!can(variable.name) || variable.name == null ? " [missing name]" : ""), (!can(variable.value) || variable.value == null ? " [missing value]" : ""), (!can(variable.type) || variable.type == null ? " [missing type]" : ""))
      : null
      if(!can(variable.name) || variable.name == null || !can(variable.value) || variable.value == null || !can(variable.type) || variable.type == null)
    ])
  }
}

# Check and validate actions variables conditional fields
# - If type is organization, visibility is required
# - If type is repository, repository is required
# - If type is environment, repository and environment are required
check "actions_variables_conditional_fields" {
  assert {
    condition = alltrue([
      for idx, variable in var.github_actions_variables :
      (can(variable.type) && variable.type != null) ? (
        (variable.type == "repository") ? (
          can(variable.repository) && variable.repository != null && variable.repository != ""
          ) : (variable.type == "environment") ? (
          can(variable.repository) && variable.repository != null && variable.repository != "" &&
          can(variable.environment) && variable.environment != null && variable.environment != ""
        ) : true
      ) : true
    ])
    error_message = join("\n", [
      for idx, variable in var.github_actions_variables :
      ((can(variable.type) && variable.type != null) && (
        (variable.type == "repository" && (
          (!can(variable.repository) || variable.repository == null || variable.repository == "")
        )) ||
        (variable.type == "environment" && (
          (!can(variable.repository) || variable.repository == null || variable.repository == "") ||
          (!can(variable.environment) || variable.environment == null || variable.environment == "")
        ))
        )) ? (
        format(
          "Invalid actions variable '%s':%s%s",
          can(variable.name) ? variable.name : format("(index %d)", idx),
          (variable.type == "repository" && (!can(variable.repository) || variable.repository == null || variable.repository == "")) ? " [type 'repository' requires repository field]" : "",
          (variable.type == "environment" && ((!can(variable.repository) || variable.repository == null || variable.repository == "") || (!can(variable.environment) || variable.environment == null || variable.environment == ""))) ? " [type 'environment' requires repository and environment fields]" : ""
        )
      ) : null
      if((can(variable.type) && variable.type != null) && (
        (variable.type == "repository" && (
          (!can(variable.repository) || variable.repository == null || variable.repository == "")
        )) ||
        (variable.type == "environment" && (
          (!can(variable.repository) || variable.repository == null || variable.repository == "") ||
          (!can(variable.environment) || variable.environment == null || variable.environment == "")
        ))
      ))
    ])
  }
}
