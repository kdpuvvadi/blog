# Providers

terraform {
  required_version = ">= 1.3.0"
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.7.1"
    }
  }
  cloud {
    organization = "KDPuvvadi"

    workspaces {
      name = "blog"
    }
  }
}
