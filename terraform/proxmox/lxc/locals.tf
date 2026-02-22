locals {
  common_tags = ["terraform"]

  defaults = {
    template     = "debian-13-standard_13.1-2_amd64.tar.zst"
    cpu          = 2
    memory       = 2048
    disk         = 15
    gateway      = "192.168.1.1"
    dns          = ["192.168.1.150"]
    unprivileged = true
  }

  containers = {
    "swarm-01" = {
      description = "Docker Swarm node 01 | IP: 192.168.1.103"
      ip          = "192.168.1.103"
      id          = 103
      tags        = ["docker", "swarm"]
    },
    "swarm-02" = {
      description = "Docker Swarm node 02 | IP: 192.168.1.104"
      ip          = "192.168.1.104"
      id          = 104
      tags        = ["docker", "swarm"]
    },
    "github-runner-01" = {
      description = "Github Runner | IP: 192.168.1.111"
      ip          = "192.168.1.111"
      id          = 111
      tags        = ["github-runner"]
    },
    "pihole-01" = {
      description = "Pihole | IP: 192.168.1.150"
      ip          = "192.168.1.150"
      id          = 150
      tags        = ["dns", "pihole"]
    },
    "unifi-controller" = {
      description  = "Unifi Controller | IP: 192.168.1.115"
      ip           = "192.168.1.115"
      id           = 115
      tags         = ["unifi-controller", "network"]
    },
    "aldagin-playground" = {
      description  = "Aldagin Playground | IP: 192.168.1.165"
      ip           = "192.168.1.165"
      id           = 165
      tags         = ["playground"]
    }
  }

  containers_merged = {
    for name, cfg in local.containers :
    name => merge(
      local.defaults,
      cfg,
      {
        cpu            = try(cfg.cpu, local.defaults.cpu)
        memory         = try(cfg.memory, local.defaults.memory)
        disk           = try(cfg.disk, local.defaults.disk)
        template       = try(cfg.template, local.defaults.template)
        unprivileged   = try(cfg.unprivileged, local.defaults.unprivileged)
        nas_mountpoint = try(cfg.mountpoint, null)
        tags           = concat(local.common_tags, try(cfg.tags, []))
      }
    )
  }
}