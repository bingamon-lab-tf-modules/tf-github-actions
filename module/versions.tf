terraform {
  required_version = ">= 1.9.0"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.13"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.3.0"
    }
  }
}
