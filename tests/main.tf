module "test" {
  source = "../module"

  providers = {
    github = github.organization
  }

  github_enterprise_slug   = "acme-corp"
  github_organization_name = "acme-engineering"

  github_organization_data = {
    "acme-engineering" = {
      id          = "O_kgDOBpZ1jA"
      name        = "acme-engineering"
      database_id = "123456789"
    }
  }

  github_actions_runner_groups = [
    {
      name                       = "test-runners"
      type                       = "organization"
      allows_public_repositories = false
      visibility                 = "all"
    },
    # Repository-scoped runner group. With visibility "all" the
    # selected_repository_ids expression short-circuits to [] and is never
    # evaluated, which is how the .id-instead-of-.repo_id bug stayed hidden.
    # This group forces it to resolve a repository name to a numeric repo_id.
    {
      name                       = "test-runners-scoped"
      type                       = "organization"
      allows_public_repositories = false
      visibility                 = "selected"
      allowed_repositories       = ["test-repo"]
    }
  ]

  github_actions_variables = [
    {
      name       = "API_BASE_URL"
      type       = "organization"
      value      = "https://api.example.com"
      visibility = "all"
    },
    # Repository-scoped organization variable, exercising the same
    # selected_repository_ids expression on github_actions_organization_variable.
    {
      name                 = "API_SCOPED_URL"
      type                 = "organization"
      value                = "https://scoped.example.com"
      visibility           = "selected"
      allowed_repositories = ["test-repo"]
    }
  ]

  # Each secret must set exactly one value field. The provider constrains
  # value / value_encrypted / encrypted_value / plaintext_value with
  # ExactlyOneOf, so the module emits exactly one argument per secret.
  #
  # Negative case, verified manually and deliberately not committed because it
  # fails the build by design:
  #
  #   { name = "NEGATIVE_NO_VALUE", type = "organization", visibility = "all" }
  #
  # produces, at `tofu validate` time:
  #   Each secret must set exactly one of: value, value_encrypted,
  #   plaintext_value, encrypted_value. Offending secret(s): NEGATIVE_NO_VALUE
  github_actions_secrets = [
    # Modern plaintext path: emits `value`.
    {
      name       = "TEST_SECRET"
      type       = "organization"
      value      = "test-value"
      visibility = "all"
    },
    # Modern encrypted path: emits `value_encrypted` plus `key_id`.
    {
      name            = "TEST_SECRET_ENCRYPTED"
      type            = "organization"
      value_encrypted = "dGVzdC1lbmNyeXB0ZWQtdmFsdWU=" # spellchecker:disable-line
      key_id          = "test-key-id"
      visibility      = "all"
    },
    # Legacy encrypted path with no key_id: emits deprecated `encrypted_value`.
    {
      name            = "TEST_SECRET_ENCRYPTED_LEGACY"
      type            = "organization"
      encrypted_value = "dGVzdC1sZWdhY3ktdmFsdWU=" # spellchecker:disable-line
      visibility      = "all"
    },
    # Repository scoping via github_actions_organization_secret_repositories.
    {
      name                 = "TEST_SECRET_SCOPED"
      type                 = "organization"
      value                = "test-scoped-value"
      visibility           = "selected"
      allowed_repositories = ["test-repo"]
    }
  ]

  github_actions_oidc_subject_claim_templates = [
    {
      type        = "organization"
      use_default = true
    }
  ]

  github_actions_permissions = {
    enabled_repositories = "all"
    allowed_actions      = "all"

    # Provider 6.11.0 attribute, exposed by the module and unmanaged (null) by
    # default. Exercised here as true because that is the only value with real
    # effect: false is never sent to the API (the provider guards on GetOk,
    # which treats a false boolean as unset), so it would test nothing.
    sha_pinning_required = true
  }
}