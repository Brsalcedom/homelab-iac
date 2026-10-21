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
    disk        = 40   # optional, GB; default keeps the template's disk
    tags        = ["rocky", "example"]
  }
}
```

The `terraform` tag is always added through `common_tags`.

Per-VM keys that override `defaults`: `cpu`, `memory`, `disk`, `clone_vm_id`, `username`, `node_name`, `bridge`, `qemu_agent`. The gateway and DNS servers always come from `defaults`.

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

## Grow a VM's disk

`disk` is the size of the boot disk (`scsi0` on `local-lvm`, as in the template) in GB. Without it the VM keeps the template's disk. Proxmox can only grow a disk: a smaller value fails.

1. Set or raise `disk` for the VM and merge. The first time, the disk isn't in the state yet, so the plan shows it as `+ disk` and can't show what changes. The provider resizes the existing volume, without creating a new one, but also sets the block's options on it: `iothread = true` (the module's default, as in the template), plus `aio = io_uring`, `cache = none`, `discard = ignore`, `ssd = false`. Before approving the apply, compare them with the disk on Proxmox:

   ```bash
   qm config <vm-id> | grep -E '^(scsi|sata|virtio|ide|unused)'
   ```

   Any other disk on the VM, apart from the cloud-init drive, would be detached, since the module only declares the boot disk.
2. Proxmox grows the virtual disk while the VM runs, but not the partition or the filesystem. The Rocky image keeps the root on LVM (`rlm/root`, XFS), so grow each layer from inside the VM:

   ```bash
   lsblk                                       # the disk shows the new size; find the partition that holds the PV
   sudo growpart /dev/sda 3                    # that partition's number; growpart is in cloud-utils-growpart
   sudo pvresize /dev/sda3
   sudo lvextend -r -l +100%FREE /dev/rlm/root # -r grows the XFS filesystem too
   df -h /
   ```

   If `lsblk` still shows the old size, rescan the disk with `echo 1 | sudo tee /sys/class/block/sda/device/rescan`.

See [Terraform: VM](/reference/terraform-vm/) for the inputs and modules of this configuration.
