terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.118.0"
    }
  }
}

provider "proxmox" {
  insecure = true
  ssh {
    agent = false
    # username/private_key sourced from PROXMOX_VE_SSH_USERNAME / PROXMOX_VE_SSH_PRIVATE_KEY
  }
}
