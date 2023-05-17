# Read data

data "cloudflare_accounts" "cloudflare_account_data" {
  name = "KD Puvvadi"
}

data "cloudflare_zones" "zone_puvvadi_me" {
  filter {
    name = "puvvadi.me"
  }
}
