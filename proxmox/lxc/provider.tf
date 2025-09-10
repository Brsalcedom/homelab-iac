terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.83.1"
    }
  }
}

provider "proxmox" {
  insecure = true
}