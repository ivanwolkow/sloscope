terraform {
  required_version = ">= 1.13.0, < 2.0.0"

  required_providers {
    spaceship = {
      source  = "namecheap/spaceship"
      version = "~> 1.0"
    }
  }

  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "imwolkow-org"

    workspaces {
      name = "sloscope-dns"
    }
  }
}
