terraform {
  required_version = ">= 1.13.0, < 2.0.0"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }

  # Bootstrap runs locally and owns state independent of infra/dns.
  backend "local" {}
}
