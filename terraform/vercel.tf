# Vercel

resource "vercel_project" "blog_project" {
  name             = "puvvadi-blog"
  framework        = "jekyll"
  build_command    = "yarn build"
  install_command  = "yarn install"
  output_directory = "_site"

  git_repository = {
    type = "github"
    repo = "kdpuvvadi/blog"
  }
}

resource "vercel_project_environment_variable" "blog_env" {
  project_id = vercel_project.blog_project.id
  key        = "BASE_URL"
  value      = "https://preview.blog.puvvadi.me"
  target     = ["production"]
}

resource "vercel_deployment" "blog_deploy" {
  project_id = vercel_project.blog_project.id
  ref        = "preview"
  production = "true"
}

resource "vercel_project_domain" "blog_preview_domain" {
  project_id = vercel_project.blog_project.id
  domain     = "preview.blog.puvvadi.me"
}