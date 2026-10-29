# GitHub Actions Module

## Table of Contents

- [GitHub Actions Module](#github-actions-module)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Dynamic Lookups](#dynamic-lookups)
    - [Enterprise Runner Groups](#enterprise-runner-groups)
    - [Organization Runner Groups](#organization-runner-groups)
    - [Organization Permissions](#organization-permissions)
  - [Features](#features)
  - [Module Documentation](#module-documentation)

## Overview

This module manages GitHub Actions settings including runner groups, variables, secrets, and OIDC configurations.

## Dynamic Lookups

### Enterprise Runner Groups

When configuring enterprise runner groups with `visibility = "selected"`, provide organization names in `allowed_organizations`. The module will automatically look up the organization IDs.

```hcl
github_actions_runner_groups = [
  {
    name = "enterprise-selected"
    type = "enterprise"
    visibility = "selected"
    allowed_organizations = ["org1", "org2", "org3"]
  }
]
```

### Organization Runner Groups

When configuring organization runner groups with `visibility = "selected"` or `visibility = "private"`, provide repository names in `allowed_repositories`. The module will automatically look up the repository IDs.

```hcl
github_actions_runner_groups = [
  {
    name = "org-selected"
    type = "organization"
    visibility = "selected"
    allowed_repositories = ["repo1", "repo2", "repo3"]
  }
]
```

### Organization Permissions

When configuring GitHub Actions organization permissions with `enabled_repositories = "selected"`, provide repository names in `enabled_repositories_config.repositories`. The module will automatically look up the repository IDs.

```hcl
github_actions_permissions = {
  enabled_repositories = "selected"
  allowed_actions = "selected"

  allowed_actions_config = {
    github_owned_allowed = true
    verified_allowed = true
    patterns_allowed = ["actions/cache@*", "actions/checkout@*"]
  }

  enabled_repositories_config = {
    repositories = ["repo1", "repo2", "repo3"]
  }
}
```

## Features

- ✅ Dynamic organization ID lookups for enterprise runner groups
- ✅ Dynamic repository ID lookups for organization runner groups
- ✅ Dynamic repository ID lookups for organization permissions
- ✅ Input validation for required fields
- ✅ Support for workflow whitelisting
- ✅ Comprehensive actions variables and secrets management
- ✅ GitHub Actions organization permissions management

## Module Documentation

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_github"></a> [github](#requirement\_github) | ~> 6.13 |
| <a name="requirement_null"></a> [null](#requirement\_null) | 3.3.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_github"></a> [github](#provider\_github) | 6.13.0 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.3.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [github_actions_environment_secret.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_environment_secret) | resource |
| [github_actions_environment_variable.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_environment_variable) | resource |
| [github_actions_organization_oidc_subject_claim_customization_template.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_organization_oidc_subject_claim_customization_template) | resource |
| [github_actions_organization_permissions.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_organization_permissions) | resource |
| [github_actions_organization_secret.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_organization_secret) | resource |
| [github_actions_organization_secret_repositories.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_organization_secret_repositories) | resource |
| [github_actions_organization_variable.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_organization_variable) | resource |
| [github_actions_repository_oidc_subject_claim_customization_template.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_repository_oidc_subject_claim_customization_template) | resource |
| [github_actions_runner_group.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_runner_group) | resource |
| [github_actions_secret.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_secret) | resource |
| [github_actions_variable.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_variable) | resource |
| [github_enterprise_actions_runner_group.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/enterprise_actions_runner_group) | resource |
| [null_resource.validate_organizations](https://registry.terraform.io/providers/hashicorp/null/3.3.0/docs/resources/resource) | resource |
| [github_organization.this](https://registry.terraform.io/providers/integrations/github/latest/docs/data-sources/organization) | data source |
| [github_repository.this](https://registry.terraform.io/providers/integrations/github/latest/docs/data-sources/repository) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_github_actions_oidc_subject_claim_templates"></a> [github\_actions\_oidc\_subject\_claim\_templates](#input\_github\_actions\_oidc\_subject\_claim\_templates) | n/a | <pre>list(object({<br/>    type = string<br/><br/>    include_claim_keys = optional(list(string), []) # default: []<br/>    use_default        = optional(bool, true)       # default: true<br/><br/>    repository = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_github_actions_permissions"></a> [github\_actions\_permissions](#input\_github\_actions\_permissions) | n/a | <pre>object({<br/>    # Required: The policy that controls the repositories in the organization that are allowed to run GitHub Actions<br/>    # Can be one of: all, none, or selected<br/>    enabled_repositories = string<br/><br/>    # Optional: The permissions policy that controls the actions that are allowed to run<br/>    # Can be one of: all, local_only, or selected<br/>    allowed_actions = optional(string, "all")<br/><br/>    # Optional: Sets the actions that are allowed in an organization<br/>    # Only available when allowed_actions = selected<br/>    allowed_actions_config = optional(object({<br/>      # Required: Whether GitHub-owned actions are allowed in the organization<br/>      github_owned_allowed = bool<br/><br/>      # Optional: Whether actions in GitHub Marketplace from verified creators are allowed<br/>      verified_allowed = optional(bool, false)<br/><br/>      # Optional: List of string-matching patterns to allow specific action(s)<br/>      # Wildcards, tags, and SHAs are allowed<br/>      patterns_allowed = optional(list(string), [])<br/>    }), null)<br/><br/>    # Optional: Sets the list of selected repositories that are enabled for GitHub Actions<br/>    # Only available when enabled_repositories = selected<br/>    # Provide repository names - IDs will be looked up automatically<br/>    enabled_repositories_config = optional(object({<br/>      repositories = list(string)<br/>    }), null)<br/><br/>    # Optional: Whether pinning to a specific SHA is required for all actions<br/>    # and reusable workflows in the organization.<br/>    #<br/>    # Exposed but unmanaged by default. Enabling it is a conscious decision<br/>    # because it forces every workflow reference to become a SHA.<br/>    #<br/>    # The default is deliberately null, NOT false. Do not "tidy" it to false:<br/>    # sha_pinning_required is Optional + Computed in the provider, and its<br/>    # update path guards on d.GetOk(), which returns ok=false for a false<br/>    # boolean (false is the zero value in terraform-plugin-sdk). So false is<br/>    # never sent to the API and cannot turn pinning off. Worse, because the<br/>    # attribute is Computed, config false against a remote value of true<br/>    # produces a diff that apply cannot resolve - a perpetual, never-<br/>    # converging plan. null means "leave whatever GitHub has", which is the<br/>    # only honest way to express "off by default" for this attribute.<br/>    sha_pinning_required = optional(bool, null)<br/>  })</pre> | `null` | no |
| <a name="input_github_actions_runner_groups"></a> [github\_actions\_runner\_groups](#input\_github\_actions\_runner\_groups) | n/a | <pre>list(object({<br/>    name = optional(string, null)<br/>    type = optional(string, null)<br/><br/>    # Whether the runner group allows public repositories<br/>    allows_public_repositories = optional(bool, false) # default: false<br/><br/>    # Visibility of the runner group<br/>    visibility = optional(string, "all") # default: "all"<br/><br/>    # For enterprise runner groups with visibility "selected":<br/>    # Provide organization names - IDs will be looked up automatically<br/>    allowed_organizations = optional(list(string), []) # default: []<br/><br/>    # For organization runner groups with visibility "selected" or "private":<br/>    # Provide repository names - IDs will be looked up automatically<br/>    allowed_repositories = optional(list(string), []) # default: []<br/><br/>    # Optional workflow whitelist to apply to the runner group<br/>    workflow_whitelist = optional(object({<br/>      enabled   = optional(bool, false)      # default: false<br/>      workflows = optional(list(string), []) # default: []<br/>      }), {<br/>      enabled   = false,<br/>      workflows = [],<br/>    })<br/>  }))</pre> | `[]` | no |
| <a name="input_github_actions_secrets"></a> [github\_actions\_secrets](#input\_github\_actions\_secrets) | n/a | <pre>list(object({<br/>    name = string<br/>    type = string<br/><br/>    # Exactly one value field must be set. The provider constrains<br/>    # value / value_encrypted / encrypted_value / plaintext_value with<br/>    # ExactlyOneOf, which rejects both "more than one" and "none at all".<br/>    value           = optional(string, null) # Plaintext value, preferred.<br/>    value_encrypted = optional(string, null) # Base64 value.<br/>    key_id          = optional(string, null) # Optional; the provider resolves it when omitted.<br/><br/>    # Legacy aliases, deprecated upstream but still accepted so existing callers<br/>    # keep working. plaintext_value maps to value, and encrypted_value maps to<br/>    # value_encrypted - unconditionally, with or without a key_id. Neither is<br/>    # passed through to a resource: the deprecated provider arguments are no<br/>    # longer emitted at all.<br/>    encrypted_value = optional(string, null)<br/>    plaintext_value = optional(string, null)<br/><br/>    visibility           = optional(string, "private") # default: "private"<br/>    allowed_repositories = optional(list(string), [])  # default: []<br/><br/>    repository  = optional(string)<br/>    environment = optional(string)<br/><br/>  }))</pre> | `[]` | no |
| <a name="input_github_actions_variables"></a> [github\_actions\_variables](#input\_github\_actions\_variables) | n/a | <pre>list(object({<br/>    name = string<br/>    type = string<br/><br/>    value = string<br/><br/>    visibility           = optional(string, "private") # default: "private"<br/>    allowed_repositories = optional(list(string), [])  # default: []<br/><br/>    repository  = optional(string)<br/>    environment = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_github_enterprise_slug"></a> [github\_enterprise\_slug](#input\_github\_enterprise\_slug) | The slug of the GitHub Enterprise where resources will be created.<br/><br/>  This is needed by the GitHub Enterprise Terraform provider.<br/><br/>  This can be set via either;<br/><br/>  - TF\_VAR\_github\_enterprise\_slug environment variable.<br/>  - github\_enterprise\_slug variable in the terraform.tfvars file. | `string` | n/a | yes |
| <a name="input_github_organization_data"></a> [github\_organization\_data](#input\_github\_organization\_data) | Map of organization data keyed by organization name to avoid unstable data source lookups | <pre>map(object({<br/>    id          = string<br/>    name        = string<br/>    database_id = string<br/>  }))</pre> | `{}` | no |
| <a name="input_github_organization_name"></a> [github\_organization\_name](#input\_github\_organization\_name) | Required. The name of the GitHub organization to create the actions in. | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_github_actions_organization_permissions"></a> [github\_actions\_organization\_permissions](#output\_github\_actions\_organization\_permissions) | GitHub Actions organization permissions configuration |
<!-- END_TF_DOCS -->
