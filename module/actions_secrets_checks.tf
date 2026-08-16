####################################################
# Checks: Actions Secrets
####################################################

# NOTE: "exactly one value field per secret" is enforced by a validation block
# on var.github_actions_secrets, not here. A check block only warns, which is
# not enough to keep a value-less secret away from the provider's ExactlyOneOf
# constraint. Name and type presence is guaranteed by the variable's type.

# Check secret uniqueness WITHIN a scope.
#
# A bare name is not the identity of a secret: the same name may exist as an
# organization secret, on two repositories, and in two environments of one
# repository, and each is a distinct secret with its own ciphertext. Asserting
# on names alone rejected those legitimate declarations. The scope key
# (organization -> name, repository -> repo/name, environment ->
# repo/env/name) matches the for_each keys in actions_secrets.tf, so this now
# catches exactly the duplicates that would collide there.
check "actions_secrets_unique_scopes" {
  assert {
    condition = length(var.github_actions_secrets) == length(distinct([
      for secret in var.github_actions_secrets :
      secret.type == "environment" ? "${secret.repository}/${secret.environment}/${secret.name}" :
      secret.type == "repository" ? "${secret.repository}/${secret.name}" :
      secret.name
    ]))
    error_message = join("\n", concat(
      ["Duplicate secrets found (same name in the same scope):"],
      [
        for scope_key, secrets in {
          for secret in var.github_actions_secrets :
          (
            secret.type == "environment" ? "${secret.repository}/${secret.environment}/${secret.name}" :
            secret.type == "repository" ? "${secret.repository}/${secret.name}" :
            secret.name
          ) => secret...
        } : scope_key
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
