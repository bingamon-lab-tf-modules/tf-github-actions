####################################################
# Checks: Actions Secrets
####################################################

# Check and validate actions secrets
# - Name is required
# - Type is required
# - Encrypted or plaintext value is required (but not both)
check "actions_secrets" {
  assert {
    condition = alltrue([
      for idx, secret in var.github_actions_secrets :
      can(secret.name) &&
      secret.name != null &&
      can(secret.type) &&
      secret.type != null &&
      (
        (can(secret.encrypted_value) && secret.encrypted_value != null && secret.encrypted_value != "" &&
        (!can(secret.plaintext_value) || secret.plaintext_value == null || secret.plaintext_value == "")) ||
        (can(secret.plaintext_value) && secret.plaintext_value != null && secret.plaintext_value != "" &&
        (!can(secret.encrypted_value) || secret.encrypted_value == null || secret.encrypted_value == ""))
      )
    ])
    error_message = join("\n", [
      for idx, secret in var.github_actions_secrets :
      (!can(secret.name) || secret.name == null || !can(secret.type) || secret.type == null ||
        !(
          (can(secret.encrypted_value) && secret.encrypted_value != null && secret.encrypted_value != "" &&
          (!can(secret.plaintext_value) || secret.plaintext_value == null || secret.plaintext_value == "")) ||
          (can(secret.plaintext_value) && secret.plaintext_value != null && secret.plaintext_value != "" &&
          (!can(secret.encrypted_value) || secret.encrypted_value == null || secret.encrypted_value == ""))
        )) ? (
        format(
          "Invalid actions secret '%s':%s%s%s",
          can(secret.name) ? secret.name : format("(index %d)", idx),
          (!can(secret.name) || secret.name == null ? " [missing name]" : ""),
          (!can(secret.type) || secret.type == null ? " [missing type]" : ""),
          (!(
            (can(secret.encrypted_value) && secret.encrypted_value != null && secret.encrypted_value != "" &&
            (!can(secret.plaintext_value) || secret.plaintext_value == null || secret.plaintext_value == "")) ||
            (can(secret.plaintext_value) && secret.plaintext_value != null && secret.plaintext_value != "" &&
            (!can(secret.encrypted_value) || secret.encrypted_value == null || secret.encrypted_value == ""))
          ) ? " [requires exactly one of encrypted_value or plaintext_value]" : "")
        )
      ) : null
      if(!can(secret.name) || secret.name == null || !can(secret.type) || secret.type == null ||
        !(
          (can(secret.encrypted_value) && secret.encrypted_value != null && secret.encrypted_value != "" &&
          (!can(secret.plaintext_value) || secret.plaintext_value == null || secret.plaintext_value == "")) ||
          (can(secret.plaintext_value) && secret.plaintext_value != null && secret.plaintext_value != "" &&
          (!can(secret.encrypted_value) || secret.encrypted_value == null || secret.encrypted_value == ""))
      ))
    ])
  }
}

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
