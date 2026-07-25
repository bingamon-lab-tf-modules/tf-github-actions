####################################################
# Checks: Actions Secrets
####################################################

# NOTE: "exactly one value field per secret" is enforced by a validation block
# on var.github_actions_secrets, not here. A check block only warns, which is
# not enough to keep a value-less secret away from the provider's ExactlyOneOf
# constraint. Name and type presence is guaranteed by the variable's type.

# Check secret name uniqueness across different types and scopes
check "actions_secrets_unique_names" {
  assert {
    condition = length(var.github_actions_secrets) == length(distinct([
      for secret in var.github_actions_secrets : secret.name
    ]))
    error_message = join("\n", concat(
      ["Duplicate secret names found:"],
      [
        for name, secrets in {
          for secret in var.github_actions_secrets : secret.name => secret...
        } : name
        if length(secrets) > 1
      ]
    ))
  }
}

# Check and validate actions secrets conditional fields
# - If type is repository, repository is required
# - If type is environment, repository and environment are required
check "actions_secrets_conditional_fields" {
  assert {
    condition = alltrue([
      for idx, secret in var.github_actions_secrets :
      (can(secret.type) && secret.type != null) ? (
        (secret.type == "repository") ? (
          can(secret.repository) && secret.repository != null && secret.repository != ""
          ) : (secret.type == "environment") ? (
          can(secret.repository) && secret.repository != null && secret.repository != "" &&
          can(secret.environment) && secret.environment != null && secret.environment != ""
        ) : true
      ) : true
    ])
    error_message = join("\n", [
      for idx, secret in var.github_actions_secrets :
      ((can(secret.type) && secret.type != null) && (
        (secret.type == "repository" && (
          (!can(secret.repository) || secret.repository == null || secret.repository == "")
        )) ||
        (secret.type == "environment" && (
          (!can(secret.repository) || secret.repository == null || secret.repository == "") ||
          (!can(secret.environment) || secret.environment == null || secret.environment == "")
        ))
        )) ? (
        format(
          "Invalid actions secret '%s':%s%s",
          can(secret.name) ? secret.name : format("(index %d)", idx),
          (secret.type == "repository" && (!can(secret.repository) || secret.repository == null || secret.repository == "")) ? " [type 'repository' requires repository field]" : "",
          (secret.type == "environment" && ((!can(secret.repository) || secret.repository == null || secret.repository == "") || (!can(secret.environment) || secret.environment == null || secret.environment == ""))) ? " [type 'environment' requires repository and environment fields]" : ""
        )
      ) : null
      if((can(secret.type) && secret.type != null) && (
        (secret.type == "repository" && (
          (!can(secret.repository) || secret.repository == null || secret.repository == "")
        )) ||
        (secret.type == "environment" && (
          (!can(secret.repository) || secret.repository == null || secret.repository == "") ||
          (!can(secret.environment) || secret.environment == null || secret.environment == "")
        ))
      ))
    ])
  }
}
