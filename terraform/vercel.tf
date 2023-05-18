# Vercel

resource "vercel_project" "blog_project" {
  name             = "puvvadi-blog"
  framework        = "hugo"
  build_command    = "hugo --gc --minify"
  install_command  = "yarn install"
  output_directory = "public"

  git_repository = {
    type = "github"
    repo = "kdpuvvadi/blog"
  }
}

resource "vercel_project_environment_variable" "blog_env_hugo" {
  project_id = vercel_project.blog_project.id
  key        = "HUGO_VERSION"
  value      = "0.110.0"
  target     = ["production"]
}

resource "vercel_project_environment_variable" "blog_env_hugo_pre" {
  project_id = vercel_project.blog_project.id
  key        = "HUGO_VERSION"
  value      = "0.110.0"
  target     = ["preview"]
}

resource "vercel_deployment" "blog_deploy" {
  project_id = vercel_project.blog_project.id
  ref        = "main"
  production = "true"
}

resource "vercel_project_domain" "blog_domain" {
  project_id = vercel_project.blog_project.id
  domain     = "blog.puvvadi.net"
}
