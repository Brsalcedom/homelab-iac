locals {
  swarm_nodes = {
    "swarm-01" = {
      description = "Docker Swarm node 01"
      ip          = "192.168.1.103"
      id          = 103
    },
    "swarm-02" = {
      description = "Docker Swarm node 02"
      ip          = "192.168.1.104"
      id          = 104
    }
  }
}

module "swarm" {
  for_each           = local.swarm_nodes
  source             = "git::https://github.com/Brsalcedom/tf-modules//proxmox/lxc?ref=v0.1.0"
  node_name          = "prox"
  vm_name            = each.key
  vm_id              = each.value.id
  os_template        = "debian-12-standard_12.7-1_amd64.tar.zst"
  vm_cpu_cores       = 2
  vm_memory          = 2048
  vm_disk_size       = 15
  vm_ipv4_address    = "${each.value.ip}/24"
  vm_ipv4_gateway    = "192.168.1.1"
  dns_server         = "192.168.1.150"
  ssh_authorized_key = var.ssh_authorized_key
  vm_description     = each.value.description
  vm_tags            = ["terraform", "swarm", "docker"]
}