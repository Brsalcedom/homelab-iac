---
title: Deploy VMs
description: Add, change or remove QEMU virtual machines with the terraform/proxmox/vm configuration.
sidebar:
  order: 2
---

`terraform/proxmox/vm` creates cloud-init VMs in Proxmox using the `proxmox/vm-cloud-init` module from [Brsalcedom/tf-modules](https://github.com/Brsalcedom/tf-modules).

## Prerequisites

- The [Rocky Linux template](/how-to/create-rocky-template/) exists.
- Your shell has the variables listed in [Environment variables](/reference/environment-variables/#proxmox-vms), including SSH access to the node for the cloud-init snippet upload.

## Add a VM

VMs are declared in the `vms` map in `terraform/proxmox/vm/locals.tf`. Any key you leave out falls back to `defaults` in the same file.

```hcl
vms = {
  # ...
  "my-new-vm" = {
    description = "My new VM | IP: 192.168.10.220"
    ip          = "192.168.10.220"
    id          = 220
    memory      = 4096 # optional, default 2048
    tags        = ["rocky", "example"]
  }
}
```

The `terraform` tag is always added through `common_tags`.

Per-VM keys that override `defaults`: `cpu`, `memory`, `clone_vm_id`, `username`, `node_name`, `bridge`, `qemu_agent`. The gateway and DNS servers always come from `defaults`.

## Apply the change

Through CI (recommended): open a pull request and merge it to `main`. The [`Tofu :: Proxmox VM`](/reference/ci-workflows/) workflow runs a plan and waits for approval on the `tofu-infra` environment before applying.

From your workstation:

```bash
cd terraform/proxmox/vm
tofu init
tofu plan
tofu apply
```

## Check the result

```bash
ssh rocky@<vm-ip>
```

See [Terraform: VM](/reference/terraform-vm/) for the inputs and modules of this configuration.
