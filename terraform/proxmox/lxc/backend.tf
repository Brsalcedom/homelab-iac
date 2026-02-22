terraform {
  backend "s3" {
    endpoint                    = "https://05458affecc5fbbbfaf7621ebd720742.r2.cloudflarestorage.com"
    bucket                      = "homelab-tfstate"
    key                         = "proxmox/lxc/terraform.tfstate"
    region                      = "auto"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
    use_path_style              = true
  }
}