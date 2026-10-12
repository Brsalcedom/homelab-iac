---
title: Getting started
description: From a fresh Proxmox VE node to a first VM managed by OpenTofu with remote state in Cloudflare R2.
sidebar:
  order: 1
---

In this tutorial you prepare a fresh Proxmox VE node so OpenTofu can manage it, then use this repository to create a virtual machine. By the end you will have:

- A dedicated `terraform@pve` user with an API token.
- A local shell configured to talk to Proxmox and to the Cloudflare R2 state bucket.
- A VM created from the `terraform/proxmox/vm` configuration.

## Before you begin

You need:

- Root access to a Proxmox VE node.
- [OpenTofu](https://opentofu.org) or [Terraform](https://www.terraform.io) 1.9 or later on your workstation.
- Access keys for the `homelab-tfstate` R2 bucket (see [Remote state on Cloudflare R2](/explanation/state-backend/)).
- An SSH key pair.
- A clone of the repository:

  ```bash
  git clone https://github.com/Brsalcedom/homelab-iac.git
  cd homelab-iac
  ```

## 1. Create the Terraform user on Proxmox

On the Proxmox host, as root, create a user, a role and an API token:

```bash
# Create the Terraform user
pveum user add terraform@pve --password 'ChangeMeStrong!'

# Create a role with the permissions used by the VM and LXC configurations
pveum role add Terraform --privs "VM.Audit VM.Allocate VM.Clone VM.PowerMgmt VM.Config.Disk VM.Config.CPU VM.Config.Memory VM.Config.Network VM.Config.HWType VM.Config.Options VM.Config.CDROM VM.Config.Cloudinit Sys.Modify Datastore.AllocateSpace Datastore.Allocate Datastore.Audit SDN.Use"

# Grant the role at the root path
pveum acl modify / --roles Terraform --users terraform@pve

# Create an API token
pveum user token add terraform@pve iac --privsep 0
```

The token secret is printed only once. Copy it now.

Check that everything was created:

```bash
pveum user list
pveum role list
pveum acl list
pveum user token list terraform@pve
```

You can see why each privilege is needed in [Proxmox permissions](/reference/proxmox-permissions/).

## 2. Allow SSH uploads of cloud-init snippets

The VM configuration uploads a cloud-init user-data snippet, which the Proxmox API cannot do. The `bpg/proxmox` provider falls back to SSH for that, so on the Proxmox node authorize your public key for `root` and enable snippets on the `local` storage:

```bash
mkdir -p ~/.ssh && chmod 700 ~/.ssh
echo "<contents of your public key>" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

pvesm set local --content backup,iso,vztmpl,snippets
```

## 3. Create the VM template

The VMs are cloned from a Rocky Linux cloud-init template with ID `8000`. Follow [Create the Rocky Linux template](/how-to/create-rocky-template/) and come back when the template exists.

## 4. Configure your shell

Export the Proxmox and R2 credentials on your workstation.

**Bash**

```bash
export PROXMOX_VE_ENDPOINT="https://<proxmox-ip>:8006/api2/json"
export PROXMOX_VE_API_TOKEN="terraform@pve!iac=<TOKEN_SECRET>"
export PROXMOX_VE_SSH_USERNAME="root"
export PROXMOX_VE_SSH_PRIVATE_KEY="$(cat ~/.ssh/id_ed25519)"
export AWS_ACCESS_KEY_ID="<R2_ACCESS_KEY>"
export AWS_SECRET_ACCESS_KEY="<R2_SECRET_KEY>"
export TF_VAR_ssh_authorized_keys='["ssh-ed25519 AAAA..."]'
```

**PowerShell**

```powershell
$env:PROXMOX_VE_ENDPOINT="https://<proxmox-ip>:8006/api2/json"
$env:PROXMOX_VE_API_TOKEN="terraform@pve!iac=<TOKEN_SECRET>"
$env:PROXMOX_VE_SSH_USERNAME="root"
$env:PROXMOX_VE_SSH_PRIVATE_KEY=Get-Content -Raw ~\.ssh\id_ed25519
$env:AWS_ACCESS_KEY_ID="<R2_ACCESS_KEY>"
$env:AWS_SECRET_ACCESS_KEY="<R2_SECRET_KEY>"
$env:TF_VAR_ssh_authorized_keys='["ssh-ed25519 AAAA..."]'
```

## 5. Plan and apply

```bash
cd terraform/proxmox/vm
tofu init
tofu plan
```

The plan lists the VMs defined in `locals.tf`. If it looks right, apply it:

```bash
tofu apply
```

## 6. Log in to the VM

Once the apply finishes, connect with the default `rocky` user:

```bash
ssh rocky@<vm-ip>
```

## Next steps

- Add your own machine: [Deploy VMs](/how-to/deploy-vms/).
- Create LXC containers: [Deploy LXC containers](/how-to/deploy-lxc-containers/).
- Build the Kubernetes cluster: [Install K3s on Hyperion](/how-to/install-k3s-hyperion/).
