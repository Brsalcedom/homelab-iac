---
title: Proxmox permissions
description: Privileges of the Terraform role used by the VM and LXC configurations.
sidebar:
  order: 2
---

OpenTofu authenticates as `terraform@pve` with the API token `terraform@pve!iac` (created with `--privsep 0`, so the token has the user's privileges). The user has the `Terraform` role on `/`.

## Privileges

| Privilege | VM | LXC | Why |
|-----------|:--:|:---:|-----|
| `VM.Audit` | ✅ | ✅ | Read guest configuration and status |
| `VM.Allocate` | ✅ | ✅ | Create and delete guests |
| `VM.Clone` | ✅ | | Clone VMs from the cloud-init template |
| `VM.PowerMgmt` | ✅ | ✅ | Start and stop guests |
| `VM.Config.Disk` | ✅ | ✅ | Disks and root filesystem |
| `VM.Config.CPU` | ✅ | ✅ | CPU cores |
| `VM.Config.Memory` | ✅ | ✅ | Memory |
| `VM.Config.Network` | ✅ | ✅ | Network interfaces |
| `VM.Config.HWType` | ✅ | ✅ | Hardware type settings |
| `VM.Config.Options` | ✅ | ✅ | Description, tags, boot options |
| `VM.Config.CDROM` | ✅ | | Cloud-init drive |
| `VM.Config.Cloudinit` | ✅ | | Cloud-init settings |
| `Sys.Modify` | ✅ | ✅ | Node-level changes made by the provider |
| `Datastore.AllocateSpace` | ✅ | ✅ | Allocate disk space |
| `Datastore.Allocate` | ✅ | | Upload the cloud-init snippet |
| `Datastore.Audit` | ✅ | ✅ | Read storage information |
| `SDN.Use` | ✅ | ✅ | Attach guests to bridges and SDN networks |

## Create the user, role and token

Run as root on the Proxmox host. This role covers both configurations:

```bash
pveum user add terraform@pve --password 'ChangeMeStrong!'
pveum role add Terraform --privs "VM.Audit VM.Allocate VM.Clone VM.PowerMgmt VM.Config.Disk VM.Config.CPU VM.Config.Memory VM.Config.Network VM.Config.HWType VM.Config.Options VM.Config.CDROM VM.Config.Cloudinit Sys.Modify Datastore.AllocateSpace Datastore.Allocate Datastore.Audit SDN.Use"
pveum acl modify / --roles Terraform --users terraform@pve
pveum user token add terraform@pve iac --privsep 0
```

To add privileges to an existing role:

```bash
pveum role modify Terraform --privs "<full list>"
```

In the web UI, tokens are under **Datacenter → Permissions → API Tokens**.

## SSH access

The VM configuration also needs SSH access to the node as `root`, because the Proxmox API can't upload `snippets`. See [Environment variables](/reference/environment-variables/#proxmox-vms).
