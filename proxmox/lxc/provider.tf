terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.82.0"
    }
  }
}

provider "proxmox" {
  insecure = true
}