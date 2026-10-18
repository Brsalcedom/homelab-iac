terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.117.0"
    }
  }
}

provider "proxmox" {
  insecure = true
}