---
title: Deploy LXC containers
description: Add, change or remove LXC containers with the terraform/proxmox/lxc configuration.
sidebar:
  order: 3
---

`terraform/proxmox/lxc` creates LXC containers in Proxmox using the `proxmox/lxc` module from [Brsalcedom/tf-modules](https://github.com/Brsalcedom/tf-modules).

## Prerequisites

- Your shell has the variables listed in [Environment variables](/reference/environment-variables/#proxmox-lxc).
- The OS template is downloaded on the node.

## Download the container template

In the Proxmox UI go to **Node → local → CT Templates → Templates** and download the template set in `defaults.template` in `locals.tf` (currently `debian-13-standard_13.6-1_amd64.tar.zst`).

## Add a container

Containers are declared in the `containers` map in `terraform/proxmox/lxc/locals.tf`. Any key you leave out falls back to `defaults`.

```hcl
containers = {
  # ...
  "my-container" = {
    description = "My container | IP: 192.168.10.180"
    ip          = "192.168.10.180"
    id          = 180
    cpu         = 4    # optional, default 2
    memory      = 4096 # optional, default 2048
    disk        = 30   # optional, default 15 (GB)
    tags        = ["example"]
  }
}
```

Other optional keys: `template`, `unprivileged` (default `true`) and `mountpoint` (passed to the module as `nas_mountpoint`).

The target node comes from the `node_name` variable (default `prox`). Override it with `TF_VAR_node_name`.

## Apply the change

Through CI: merge to `main`; the [`Tofu :: Proxmox LXC`](/reference/ci-workflows/) workflow plans and applies.

From your workstation:

```bash
cd terraform/proxmox/lxc
tofu init
tofu plan
tofu apply
```

## Check the result

```bash
ssh root@<container-ip>
```

Then confirm CPU, memory, disk, tags, description and network settings in the Proxmox UI.

See [Terraform: LXC](/reference/terraform-lxc/) for the inputs and modules of this configuration.
