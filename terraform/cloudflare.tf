# Cloudflare project deployment and DNS record for the project

resource "cloudflare_pages_project" "blog_pages_project" {
  account_id        = data.cloudflare_accounts.cloudflare_account_data.accounts[0].id
  name              = "blog"
  production_branch = "main"

  source {
    type = "github"
    config {
      owner                         = "kdpuvvadi"
      repo_name                     = "blog"
      production_branch             = "main"
      pr_comments_enabled           = true
      deployments_enabled           = true
      production_deployment_enabled = true
      preview_deployment_setting    = "all"
      preview_branch_includes       = ["*"]
      preview_branch_excludes       = ["main", "prod"]
    }
  }

  build_config {
    build_command       = "hugo --gc --minify"
    destination_dir     = "public"
    root_dir            = ""
    web_analytics_tag   = "6d04d8997a0846debf452bda420ccde9"
    web_analytics_token = "cda715889e4b41d89cfdac386f19f8ae"
  }

  deployment_configs {
    preview {
      environment_variables = {
        HUGO_VERSION = "0.114.0"
        NODE_VERSION = "18.16.0"
      }
      fail_open = true
    }
    production {
      environment_variables = {
        HUGO_VERSION = "0.113.0"
        NODE_VERSION = "16.20.0"
      }
      fail_open = true
    }
  }
}

resource "cloudflare_pages_domain" "cloudflare_blog_domain" {
  account_id   = data.cloudflare_accounts.cloudflare_account_data.accounts[0].id
  project_name = cloudflare_pages_project.blog_pages_project.name
  domain       = "blog.puvvadi.me"
}

resource "cloudflare_record" "cloudflare_blog_record" {
  zone_id         = data.cloudflare_zones.zone_puvvadi_me.zones[0].id
  name            = "blog"
  value           = cloudflare_pages_project.blog_pages_project.subdomain
  type            = "CNAME"
  proxied         = true
  ttl             = 1
  allow_overwrite = true
}
