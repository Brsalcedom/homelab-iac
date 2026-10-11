terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.97.0"
    }
  }
}

provider "proxmox" {
  insecure = true
  ssh {
    agent       = false
    username    = "root" # OS user with id_rsa.pub in authorized_keys on the Proxmox node
    private_key = file("C:\\Users\\Cervant\\.ssh\\id_rsa")
  }
}
