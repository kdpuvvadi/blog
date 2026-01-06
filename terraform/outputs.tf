# Outputs

output "cloudflare_blog_url" {
  value = cloudflare_record.cloudflare_blog_cname_record.hostname
}
