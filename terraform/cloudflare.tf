# Cloudflare project deployment and DNS record for the project
resource "cloudflare_pages_project" "blog_pages_project" {
  account_id        = "785a966c2bc174e625f1140eedfd6a89"
  name              = "blog"
  production_branch = "main"

  source = {
    type = "github"
    config = {
      owner     = "kdpuvvadi"
      repo_name = "blog"

      production_branch       = "main"
      pr_comments_enabled     = true
      deployments_enabled     = true
      preview_branch_includes = ["*"]
      preview_branch_excludes = ["main", "prod"]
    }
  }

  build_config = {
    build_command   = "bundle install && bundle exec jekyll build --config $CONFIG_FILE"
    destination_dir = "_site"
    root_dir        = ""
    build_caching   = true
  }

  deployment_configs = {
    preview = {
      env_vars = {
        CONFIG_FILE  = { value = "_config_preview.yml", type = "plain_text" }
        JEKYLL_ENV   = { value = "development", type = "plain_text" }
        RUBY_VERSION = { value = "3.4.4", type = "plain_text" }
      }
      fail_open                 = true
      build_image_major_version = 3
    }

    production = {
      env_vars = {
        CONFIG_FILE  = { value = "_config.yml", type = "plain_text" }
        JEKYLL_ENV   = { value = "production", type = "plain_text" }
        RUBY_VERSION = { value = "3.4.4", type = "plain_text" }
      }
      fail_open                 = true
      build_image_major_version = 3
    }
  }
}


resource "cloudflare_pages_domain" "cloudflare_blog_domain" {
  account_id   = "785a966c2bc174e625f1140eedfd6a89"
  project_name = cloudflare_pages_project.blog_pages_project.name
  name         = "puvvadi.net"
  depends_on   = [cloudflare_dns_record.cloudflare_blog_cname_record]
}

resource "cloudflare_dns_record" "cloudflare_blog_cname_record" {
  zone_id = "be6fbe11f57bd4fabbf5748235a6b1b8"
  name    = "@"
  content = cloudflare_pages_project.blog_pages_project.subdomain
  type    = "CNAME"
  proxied = true
  ttl     = 1
}
