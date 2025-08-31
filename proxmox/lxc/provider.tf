terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.83.0"
    }
  }
}

provider "proxmox" {
  insecure = true
}