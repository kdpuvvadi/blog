# Outputs

output "cloudflare_blog_cname" {
  value = cloudflare_pages_project.blog_pages_project.subdomain
}

output "cloudflare_blog_url" {
  value = cloudflare_record.cloudflare_blog_record.hostname
}

output "vercel_blog_cname" {
  value = vercel_deployment.blog_deploy.domains[1]
}

output "vercel_blog_url" {
  value = cloudflare_record.vercel_blog_record.hostname
}
