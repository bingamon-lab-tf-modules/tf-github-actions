terraform {
  required_version = ">= 1.9.0"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "6.8.3"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.4"
    }
  }
}
