# Outputs

output "cloudflare_blog_cname" {
  value = cloudflare_pages_project.blog_pages_project.subdomain
}

output "cloudflare_blog_url" {
  value = cloudflare_record.cloudflare_blog_record_cname.hostname
}
