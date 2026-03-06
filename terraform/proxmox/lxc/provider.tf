terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.98.0"
    }
  }
}

provider "proxmox" {
  insecure = true
}