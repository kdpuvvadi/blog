# Outputs

output "cloudflare_edata_cname" {
  value = cloudflare_pages_project.blog_pages_project.subdomain
}

output "cloudflare_edata_url" {
  value = cloudflare_record.cloudflare_blog_record.hostname
}
