resource "cloudflare_r2_bucket" "homelab_tfstate" {
  account_id    = var.cloudflare_account_id
  name          = "homelab-tfstate"
  storage_class = "Standard"
  location      = "WNAM"
}