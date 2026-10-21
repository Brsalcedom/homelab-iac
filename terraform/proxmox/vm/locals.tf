locals {
  common_tags = ["terraform"]

  defaults = {
    clone_vm_id = 8000 # Rocky Linux cloud-init template
    cpu         = 2
    memory      = 2048
    gateway     = "192.168.10.1"
    dns         = ["192.168.10.150"]
    username    = "rocky"
    node_name   = "prox-01"
    bridge      = "vmbr0"
    qemu_agent  = false
  }

  vms = {
    "hyperion-01" = {
      description = "Hyperion 01 | K3s Cluster Node | IP: 192.168.10.201"
      ip          = "192.168.10.201"
      id          = 201
      memory      = 10240
      tags        = ["rocky", "kubernetes", "k3s"]
    },
    "hermes-agent" = {
      description = "Hermes Agent | AI Agent | IP: 192.168.10.215"
      ip          = "192.168.10.215"
      id          = 215
      memory      = 6144
      tags        = ["rocky", "hermes", "ai"]
    }
  }

  vms_merged = {
    for name, cfg in local.vms :
    name => merge(
      local.defaults,
      cfg,
      {
        cpu         = try(cfg.cpu, local.defaults.cpu)
        memory      = try(cfg.memory, local.defaults.memory)
        clone_vm_id = try(cfg.clone_vm_id, local.defaults.clone_vm_id)
        username    = try(cfg.username, local.defaults.username)
        node_name   = try(cfg.node_name, local.defaults.node_name)
        bridge      = try(cfg.bridge, local.defaults.bridge)
        qemu_agent  = try(cfg.qemu_agent, local.defaults.qemu_agent)
        tags        = concat(local.common_tags, try(cfg.tags, []))
      }
    )
  }
}
