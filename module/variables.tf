variable "github_enterprise_slug" {
  type        = string
  description = <<EOT
  The slug of the GitHub Enterprise where resources will be created.

  This is needed by the GitHub Enterprise Terraform provider.

  This can be set via either;

  - TF_VAR_github_enterprise_slug environment variable.
  - github_enterprise_slug variable in the terraform.tfvars file.
  EOT
}

variable "github_organization_name" {
  type        = string
  description = "Required. The name of the GitHub organization to create the actions in."
}

variable "github_organization_data" {
  type = map(object({
    id          = string
    name        = string
    database_id = string
  }))
  description = "Map of organization data keyed by organization name to avoid unstable data source lookups"
  default     = {}
}

variable "github_actions_runner_groups" {
  type = list(object({
    name = optional(string, null)
    type = optional(string, null)

    # Whether the runner group allows public repositories
    allows_public_repositories = optional(bool, false) # default: false

    # Visibility of the runner group
    visibility = optional(string, "all") # default: "all"

    # For enterprise runner groups with visibility "selected":
    # Provide organization names - IDs will be looked up automatically
    allowed_organizations = optional(list(string), []) # default: []

    # For organization runner groups with visibility "selected" or "private":
    # Provide repository names - IDs will be looked up automatically
    allowed_repositories = optional(list(string), []) # default: []

    # Optional workflow whitelist to apply to the runner group
    workflow_whitelist = optional(object({
      enabled   = optional(bool, false)      # default: false
      workflows = optional(list(string), []) # default: []
      }), {
      enabled   = false,
      workflows = [],
    })
  }))

  default = []

  validation {
    condition = alltrue([
      for group in var.github_actions_runner_groups :
      group.type == "enterprise" && group.visibility == "selected"
      ? length(group.allowed_organizations) > 0
      : true
    ])
    error_message = "Enterprise runner groups with visibility 'selected' must specify allowed_organizations."
  }

  validation {
    condition = alltrue([
      for group in var.github_actions_runner_groups :
      group.type == "organization" && contains(["selected", "private"], group.visibility)
      ? length(group.allowed_repositories) > 0
      : true
    ])
    error_message = "Organization runner groups with visibility 'selected' or 'private' must specify allowed_repositories."
  }
}

variable "github_actions_variables" {
  type = list(object({
    name = string
    type = string

    value = string

    visibility           = optional(string, "private") # default: "private"
    allowed_repositories = optional(list(string), [])  # default: []

    repository  = optional(string)
    environment = optional(string)
  }))

  default = []
}

variable "github_actions_secrets" {
  type = list(object({
    name = string
    type = string

    encrypted_value = optional(string, null)
    plaintext_value = optional(string, null)

    visibility           = optional(string, "private") # default: "private"
    allowed_repositories = optional(list(string), [])  # default: []

    repository  = optional(string)
    environment = optional(string)

  }))

  default = []
}

variable "github_actions_oidc_subject_claim_templates" {
  type = list(object({
    type = string

    include_claim_keys = optional(list(string), []) # default: []
    use_default        = optional(bool, true)       # default: true

    repository = optional(string)
  }))

  default = []
}

variable "github_actions_permissions" {
  type = object({
    # Required: The policy that controls the repositories in the organization that are allowed to run GitHub Actions
    # Can be one of: all, none, or selected
    enabled_repositories = string

    # Optional: The permissions policy that controls the actions that are allowed to run
    # Can be one of: all, local_only, or selected
    allowed_actions = optional(string, "all")

    # Optional: Sets the actions that are allowed in an organization
    # Only available when allowed_actions = selected
    allowed_actions_config = optional(object({
      # Required: Whether GitHub-owned actions are allowed in the organization
      github_owned_allowed = bool

      # Optional: Whether actions in GitHub Marketplace from verified creators are allowed
      verified_allowed = optional(bool, false)

      # Optional: List of string-matching patterns to allow specific action(s)
      # Wildcards, tags, and SHAs are allowed
      patterns_allowed = optional(list(string), [])
    }), null)

    # Optional: Sets the list of selected repositories that are enabled for GitHub Actions
    # Only available when enabled_repositories = selected
    # Provide repository names - IDs will be looked up automatically
    enabled_repositories_config = optional(object({
      repositories = list(string)
    }), null)
  })

  default = null

  validation {
    condition     = var.github_actions_permissions == null ? true : contains(["all", "none", "selected"], var.github_actions_permissions.enabled_repositories)
    error_message = "enabled_repositories must be one of: all, none, or selected."
  }

  validation {
    condition     = var.github_actions_permissions == null ? true : var.github_actions_permissions.allowed_actions == null ? true : contains(["all", "local_only", "selected"], var.github_actions_permissions.allowed_actions)
    error_message = "allowed_actions must be one of: all, local_only, or selected."
  }

  validation {
    condition = (
      var.github_actions_permissions == null ? true :
      var.github_actions_permissions.allowed_actions == "selected" ?
      var.github_actions_permissions.allowed_actions_config != null : true
    )
    error_message = "allowed_actions_config is required when allowed_actions is set to 'selected'."
  }

  validation {
    condition = (
      var.github_actions_permissions == null ? true :
      var.github_actions_permissions.enabled_repositories == "selected" ?
      var.github_actions_permissions.enabled_repositories_config != null &&
      length(var.github_actions_permissions.enabled_repositories_config.repositories) > 0 : true
    )
    error_message = "enabled_repositories_config with repositories list is required when enabled_repositories is set to 'selected'."
  }
}
