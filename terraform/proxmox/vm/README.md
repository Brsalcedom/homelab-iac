# Proxmox VM --- Terraform Module

This directory contains Terraform configuration files to deploy QEMU
virtual machines in Proxmox using the bpg/proxmox provider and storing
Terraform state remotely in a Cloudflare R2 S3-compatible bucket.

The Terraform module used in this configuration is custom-built and
publicly available at:

https://github.com/Brsalcedom/tf-modules

Specifically, the proxmox/vm-cloud-init module from that repository is
used to standardize and simplify the creation of cloud-init VMs.

------------------------------------------------------------------------

## Directory Structure

```bash
terraform/proxmox/vm/
├── backend.tf      # Cloudflare R2 backend configuration
├── provider.tf     # Proxmox provider configuration
├── locals.tf       # Local variables and VM definitions
├── vms.tf          # VM module calls
└── variables.tf    # Input variables (SSH keys, etc.)
```

------------------------------------------------------------------------

## Purpose

This Terraform configuration allows you to:

- Create and manage QEMU VMs in Proxmox automatically.
- Use Cloudflare R2 as a remote backend for Terraform state.
- Define CPU, RAM, network configuration, descriptions, tags, and SSH keys.
- Clone from a cloud-init enabled VM template.

The setup is fully generic and extensible.

------------------------------------------------------------------------

## Requirements

### 1. Terraform

Recommended version: 1.8+

### 2. Proxmox API Access

You must create:

- A Proxmox user, e.g.: terraform@pve
- A role with permissions such as:
  - `VM.Audit`
  - `VM.Allocate`
  - `VM.Clone`
  - `VM.PowerMgmt`
  - `VM.Config.Disk`
  - `VM.Config.CPU`
  - `VM.Config.Memory`
  - `VM.Config.Network`
  - `VM.Config.HWType`
  - `VM.Config.Options`
  - `VM.Config.CDROM`
  - `VM.Config.Cloudinit`
  - `Sys.Modify`
  - `Datastore.AllocateSpace`
  - `Datastore.Allocate`
  - `Datastore.Audit`
  - `SDN.Use`
- An API token, for example:
  terraform@pve!iac

In Proxmox GUI:
Datacenter -> Permissions -> API Tokens

#### CLI setup on the Proxmox host

Run these commands as root on the Proxmox node:

```bash
# Create the Terraform user
pveum user add terraform@pve --password 'ChangeMeStrong!'

# Create a role with the permissions expected by this repo
pveum role add Terraform --privs "VM.Audit VM.Allocate VM.Clone VM.PowerMgmt VM.Config.Disk VM.Config.CPU VM.Config.Memory VM.Config.Network VM.Config.HWType VM.Config.Options VM.Config.CDROM VM.Config.Cloudinit Sys.Modify Datastore.AllocateSpace Datastore.Allocate Datastore.Audit SDN.Use"

# Grant the role to the user at the root path
pveum acl modify / --roles Terraform --users terraform@pve

# Create an API token for Terraform
pveum user token add terraform@pve iac --privsep 0
```

The token secret will be printed once. Keep it safe and export it later as:

```bash
export PROXMOX_VE_API_TOKEN="terraform@pve!iac=<TOKEN_SECRET>"
```

You can verify the setup with:

```bash
pveum user list
pveum role list
pveum acl list
pveum user token list terraform@pve
```

### 3. Required Environment Variables

#### Proxmox provider

```bash
export PROXMOX_VE_ENDPOINT="https://<proxmox-ip>:8006/api2/json"
export PROXMOX_VE_API_TOKEN="<USER@REALM!TOKENID=SECRET>"
# Windows
$env:PROXMOX_VE_ENDPOINT="https://<proxmox-ip>:8006/api2/json"
$env:PROXMOX_VE_API_TOKEN="<USER@REALM!TOKENID=SECRET>"
```

#### Cloudflare R2 (S3 backend)

```bash
export AWS_ACCESS_KEY_ID="<R2_ACCESS_KEY>"
export AWS_SECRET_ACCESS_KEY="<R2_SECRET_KEY>"
# Windows
$env:AWS_ACCESS_KEY_ID="<R2_ACCESS_KEY>"
$env:AWS_SECRET_ACCESS_KEY="<R2_SECRET_KEY>"
```

### 4. SSH Access for Cloud-Init Snippet Upload

The Proxmox API does not support uploading `snippets` content (used for
the cloud-init user-data file). The `bpg/proxmox` provider falls back to
a direct SSH connection to the node for this, configured in the `ssh`
block of `provider.tf` — this is separate from the API token and requires
an actual OS-level user (e.g. `root`) with the key authorized:

```bash
# On the Proxmox node, authorize your local public key for the SSH user
# configured in provider.tf (ssh.username)
mkdir -p ~/.ssh && chmod 700 ~/.ssh
echo "<contents of id_rsa.pub>" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

Also make sure the target storage (e.g. `local`) has the **Snippets**
content type enabled, otherwise the upload fails:

```bash
pvesm set local --content backup,iso,vztmpl,snippets
```

------------------------------------------------------------------------

## Preparing the Rocky Linux Template

Before deploying VMs, create a cloud-init template in Proxmox.

TODO: Replace these manual steps with Terraform + Packer to build the initial image.

### Step-by-step process:

#### 1. Download Rocky Linux cloud image

Download the cloud image to your local machine from:
https://download.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud.latest.x86_64.qcow2

Or for Rocky 10:
https://dl.rockylinux.org/pub/rocky/10/images/x86_64/Rocky-10-GenericCloud-Base.latest.x86_64.qcow2

#### 2. Create a blank VM in Proxmox

In Proxmox GUI:
- Create VM with desired ID (e.g., 200 or 201)
- General: Set name (e.g., "rocky-template")
- OS: Select "Do not use any media"
- System: Leave defaults (SeaBIOS is fine)
- Disks: **Delete the default disk**
- CPU: Set minimal (e.g., 2 cores)
- Memory: Set minimal (e.g., 2048 MB)
- Network: Add interface on bridge (vmbr0)
- Confirm: **Do not start VM yet**

#### 3. Upload the qcow2 image to Proxmox

From your local machine (PowerShell):

```powershell
scp C:\path\to\Rocky-10-GenericCloud-Base.latest.x86_64.qcow2 root@<proxmox-ip>:/tmp/
```

Or download directly on the Proxmox node via SSH:

```bash
ssh root@<proxmox-ip>
cd /tmp
wget https://download.rockylinux.org/pub/rocky/10/images/x86_64/Rocky-10-GenericCloud-Base.latest.x86_64.qcow2
```

#### 4. Import the disk to the VM

SSH to the Proxmox node and run:

```bash
qm importdisk <VMID> /tmp/Rocky-10-GenericCloud-Base.latest.x86_64.qcow2 local-lvm
```

Example:
```bash
qm importdisk 200 /tmp/Rocky-10-GenericCloud-Base.latest.x86_64.qcow2 local-lvm
```

The disk will appear as "Unused Disk 0" in the VM hardware.

#### 5. Attach the imported disk as scsi0

In Proxmox GUI:
- Go to VM → Hardware
- Double-click on "Unused Disk 0"
- Select **SCSI** as bus/device
- Ensure it's attached as **scsi0**
- Click "Add"

#### 6. Add cloud-init drive

In Proxmox GUI:
- Hardware → Add → CloudInit Drive
- Select storage (e.g., local-lvm)
- It will be added as **scsi1** or **ide2**

#### 7. Configure boot order

In Proxmox GUI:
- Options → Boot Order
- Enable and set **scsi0** (the imported disk) as first boot device
- Network boot can be second
- CloudInit drive should be last

#### 8. Verify network interface

In Proxmox GUI:
- Hardware → Network Device
- Ensure it's set to bridge **vmbr0** (or your network bridge)
- Model: VirtIO (recommended)

#### 9. Test the VM

- Start the VM
- Open Console (noVNC)
- Verify it boots correctly and obtains an IP via DHCP
- Cloud-init should run automatically
- Check `/var/log/cloud-init.log` if needed

#### 10. Convert to template

Once verified:
- **Stop the VM**
- Right-click on VM → **Convert to Template**

The template is now ready. In this configuration, the template ID is set to 201.

------------------------------------------------------------------------

## Usage

### 1. Initialize Terraform

```bash
cd terraform/proxmox/vm
terraform init
```

### 2. Review the plan

```bash
terraform plan
```

### 3. Apply changes

```bash
terraform apply
```

Terraform will create the defined VMs and configure them based on your
module parameters.

------------------------------------------------------------------------

## Example: Defining VMs

An example vms.tf might look like:

```hcl
locals {
  vms = {
    "rocky-vm-01" = {
      id          = 210
      ip          = "192.168.1.210"
      description = "Rocky Linux VM 01"
    }
  }
}

module "vms" {
  for_each            = local.vms
  source              = "git::https://github.com/Brsalcedom/tf-modules//proxmox/vm-cloud-init?ref=v1.2.0"
  node_name           = "prox"
  vm_name             = each.key
  vm_id               = each.value.id
  clone_vm_id         = 201
  vm_cpu_cores        = 2
  vm_memory           = 2048
  vm_ipv4_address     = "${each.value.ip}/24"
  vm_ipv4_gateway     = "192.168.1.1"
  dns_servers         = ["192.168.1.150"]
  ssh_authorized_keys = var.ssh_authorized_keys
  vm_username         = "rocky"
  vm_description      = each.value.description
  vm_tags             = ["terraform", "vm"]
  bridge              = "vmbr0"
  qemu_agent          = true
}
```

------------------------------------------------------------------------

## Variables

variables.tf example:

```hcl
variable "ssh_authorized_keys" {
  description = "List of SSH public keys to inject into the VM"
  type        = list(string)
}
```

Export via environment variable:

```bash
export TF_VAR_ssh_authorized_keys='["ssh-ed25519 AAAA..."]'
```

------------------------------------------------------------------------

## Post-Deployment Checks

### 1. SSH into the VM

```bash
ssh rocky@<vm-ip>
```
