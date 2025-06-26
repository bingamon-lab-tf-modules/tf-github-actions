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
    }
  ]

  github_actions_variables = [
    {
      name       = "API_BASE_URL"
      type       = "organization"
      value      = "https://api.example.com"
      visibility = "all"
    }
  ]

  github_actions_secrets = [
    {
      name            = "TEST_SECRET"
      type            = "organization"
      plaintext_value = "test-value"
      visibility      = "all"
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
  }
}