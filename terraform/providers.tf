# Providers

terraform {
  required_version = ">= 4.47.0"
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.17.0"
    }
  }
  cloud {
    organization = "KDPuvvadi"

    workspaces {
      name = "blog"
    }
  }
}
