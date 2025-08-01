resource "cloudflare_r2_bucket" "homelab_tfstate" {
  account_id    = var.cloudflare_account_id
  name          = local.homelab_bucket_name
  storage_class = "Standard"
  location      = "wnam"
}

resource "cloudflare_r2_custom_domain" "custom_domain" {
  account_id  = var.cloudflare_account_id
  zone_id     = var.cloudflare_zone_id
  bucket_name = local.homelab_bucket_name
  domain      = local.homelab_bucket_domain
  enabled     = true
  min_tls     = "1.3"
}