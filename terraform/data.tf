# Read data

data "cloudflare_accounts" "cloudflare_account_data" {
  name = "KD Puvvadi"
}

data "cloudflare_zones" "zone_blog" {
  filter {
    name = "puvvadi.net"
  }
}

data "cloudflare_zones" "zone_blog_alias" {
  filter {
    name = "puvvadi.me"
  }
}
