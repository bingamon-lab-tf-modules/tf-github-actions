provider "github" {
  alias = "enterprise"

  base_url       = "https://api.github.com"
  write_delay_ms = 1000
  read_delay_ms  = 1000
  retryable_errors = [
    "500",
    "502",
    "503",
    "504"
  ]
  max_retries = 3
}

# GitHub Organization Provider
# OpenTofu v1.9 Dynamic Providers
# Reference: GitHub Issue #2280, #769
provider "github" {
  alias = "organization"

  owner = "MyOrganization"

  base_url       = "https://api.github.com"
  write_delay_ms = 1000
  read_delay_ms  = 1000
  retryable_errors = [
    "500",
    "502",
    "503",
    "504"
  ]
  max_retries = 3
}
