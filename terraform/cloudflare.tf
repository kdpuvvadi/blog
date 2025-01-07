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
    build_command       = "jekyll build --config $CONFIG_FILE"
    destination_dir     = "_site"
    root_dir            = ""
    web_analytics_tag   = "359f78cfd77a4d92be4986bff4c02cc4"
    web_analytics_token = "3cb459fe825f4dfc987979a2e512dd34"
    build_caching       = true
  }

  deployment_configs {
    preview {
      environment_variables = {
        NODE_VERSION = "22.12.0"
        CONFIG_FILE  = "_config_preview.yml"
        JEKYLL_ENV   = "development"
      }
      fail_open = true
    }
    production {
      environment_variables = {
        NODE_VERSION = "20.18.1"
        CONFIG_FILE  = "_config.yml"
        JEKYLL_ENV   = "production"
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
  content         = cloudflare_pages_project.blog_pages_project.subdomain
  type            = "CNAME"
  proxied         = true
  ttl             = 1
  allow_overwrite = true
}
