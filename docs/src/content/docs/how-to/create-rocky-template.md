---
title: Create the Rocky Linux template
description: Build the Rocky Linux cloud-init template that the VM configuration clones from.
sidebar:
  order: 1
---

The VM configuration in `terraform/proxmox/vm` clones every machine from a cloud-init template. The template ID is set in `locals.tf` (`defaults.clone_vm_id`, currently `8000`).

:::note
These are manual steps. The plan is to replace them with Packer.
:::

## 1. Download the cloud image

Pick a Rocky Linux GenericCloud image:

- Rocky 10: `https://dl.rockylinux.org/pub/rocky/10/images/x86_64/Rocky-10-GenericCloud-Base.latest.x86_64.qcow2`
- Rocky 9: `https://download.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud.latest.x86_64.qcow2`

Download it directly on the Proxmox node:

```bash
ssh root@<proxmox-ip>
cd /tmp
wget https://dl.rockylinux.org/pub/rocky/10/images/x86_64/Rocky-10-GenericCloud-Base.latest.x86_64.qcow2
```

Or copy it from your workstation:

```powershell
scp C:\path\to\Rocky-10-GenericCloud-Base.latest.x86_64.qcow2 root@<proxmox-ip>:/tmp/
```

## 2. Create a blank VM

In the Proxmox web UI, create a VM with:

| Tab     | Setting                                                        |
|---------|----------------------------------------------------------------|
| General | ID matching `clone_vm_id` (e.g. `8000`), name `rocky-template` |
| OS      | **Do not use any media**                                       |
| System  | Defaults (SeaBIOS is fine)                                     |
| Disks   | **Delete the default disk**                                    |
| CPU     | 2 cores                                                        |
| Memory  | 2048 MB                                                        |
| Network | Bridge `vmbr0`, model VirtIO                                   |

Do not start the VM.

## 3. Import the disk

On the Proxmox node:

```bash
qm importdisk <VMID> /tmp/Rocky-10-GenericCloud-Base.latest.x86_64.qcow2 local-lvm
```

The disk appears as **Unused Disk 0** in the VM's hardware list.

## 4. Attach the disk and the cloud-init drive

1. In **Hardware**, double-click **Unused Disk 0**, select the **SCSI** bus and make sure it is attached as `scsi0`.
2. Add a **CloudInit Drive** (**Hardware → Add → CloudInit Drive**) on `local-lvm`. It is added as `scsi1` or `ide2`.

## 5. Set the boot order

In **Options → Boot Order**, enable `scsi0` and move it first. Network boot can be second; the cloud-init drive goes last.

## 6. Test the VM

1. Start the VM and open the noVNC console.
2. Check that it boots, gets an IP over DHCP and that cloud-init runs. Look at `/var/log/cloud-init.log` if something fails.

## 7. Convert it to a template

Stop the VM, right-click it and choose **Convert to Template**.

The template is ready for [Deploy VMs](/how-to/deploy-vms/).
