terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.81.0"
    }
  }
}

provider "proxmox" {
  insecure = true
}