# Proxmox LXC --- Terraform Module

This directory contains Terraform configuration files to deploy **LXC
containers in Proxmox** using the `bpg/proxmox` provider and storing
Terraform state remotely in a Cloudflare R2 S3-compatible bucket.

The Terraform module used in this configuration is **custom-built by
me** and publicly available at:

👉 **https://github.com/Brsalcedom/tf-modules**

Specifically, the `proxmox/lxc` module from that repository is used to
standardize and simplify the creation of LXC containers.

------------------------------------------------------------------------

## 📦 Directory Structure

```bash
terraform/proxmox/lxc/
├── backend.tf      # Cloudflare R2 backend configuration
├── provider.tf     # Proxmox provider configuration
├── locals.tf       # Local variables and container definitions
├── containers.tf   # LXC container module calls
└── variables.tf    # Input variables (SSH keys, etc.)
```

------------------------------------------------------------------------

## 🎯 Purpose

This Terraform configuration allows you to:

-   Create and manage **LXC containers** in Proxmox automatically.
-   Use Cloudflare R2 as a **remote backend** for Terraform state.
-   Define CPU, RAM, disk size, network configuration, descriptions,
    tags, and SSH keys.
-   Reuse your own LXC module or any external module.
-   Deploy any type of container: Swarm nodes, Kubernetes workers,
    utility servers, monitoring agents, etc.

The setup is fully generic and extensible.

------------------------------------------------------------------------

## 🔧 Requirements

### 1. Terraform

Recommended version: **1.8+**

### 2. Proxmox API Access

You must create:

-   A **Proxmox user**, e.g.: `terraform@pve`
-   A **role** with permissions such as:
    -   `VM.Audit`
    -   `VM.Allocate`
    -   `VM.Config.*`
    -   `Sys.Modify`
    -   `Datastore.AllocateSpace`
-   An **API token**, for example:\
    `terraform@pve!iac`

In Proxmox GUI:\
**Datacenter → Permissions → API Tokens**

### 3. Required Environment Variables

#### Proxmox provider

``` bash
export PROXMOX_VE_ENDPOINT="https://<proxmox-ip>:8006/api2/json"
export PROXMOX_VE_API_TOKEN="<USER@REALM!TOKENID=SECRET>"
# Windows
$env:PROXMOX_VE_ENDPOINT="https://<proxmox-ip>:8006/api2/json"
$env:PROXMOX_VE_API_TOKEN="<USER@REALM!TOKENID=SECRET>"
```

#### Cloudflare R2 (S3 backend)

``` bash
export AWS_ACCESS_KEY_ID="<R2_ACCESS_KEY>"
export AWS_SECRET_ACCESS_KEY="<R2_SECRET_KEY>"
# Windows
$env:AWS_ACCESS_KEY_ID="<R2_ACCESS_KEY>"
$env:AWS_SECRET_ACCESS_KEY="<R2_SECRET_KEY>"
```

------------------------------------------------------------------------

## 📥 Preparing the LXC Template

Before deploying containers, ensure that the required LXC template is
available on Proxmox.

From Proxmox GUI:

1.  Go to **Node → local → CT Templates**
2.  Click **Templates**
3.  Download a template such as:
    -   `debian-13-standard_13.1-2_amd64.tar.zst`
    -   or any other supported OS template

------------------------------------------------------------------------

## 🛠️ Usage

### 1. Initialize Terraform

```bash
cd terraform/proxmox/lxc
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

Terraform will create the defined LXC containers and configure them
based on your module parameters.

------------------------------------------------------------------------

## 🧩 Example: Defining Containers

An example `containers.tf` might look like:

``` hcl
locals {
  containers = {
    "app-01" = {
      id          = 201
      ip          = "192.168.1.50"
      description = "Application server"
    }
    "utils-01" = {
      id          = 202
      ip          = "192.168.1.51"
      description = "Utility container"
    }
  }
}

module "containers" {
  for_each            = local.containers
  source              = "git::https://github.com/Brsalcedom/tf-modules//proxmox/lxc?ref=v0.2.0"
  node_name           = "prox"
  vm_name             = each.key
  vm_id               = each.value.id
  os_template         = "debian-13-standard_13.1-2_amd64.tar.zst"
  vm_cpu_cores        = 2
  vm_memory           = 2048
  vm_disk_size        = 15
  vm_ipv4_address     = "${each.value.ip}/24"
  vm_ipv4_gateway     = "192.168.1.1"
  dns_servers         = ["192.168.1.150"]
  ssh_authorized_keys = var.ssh_authorized_keys
  vm_description      = each.value.description
  vm_tags             = ["terraform", "lxc"]
}
```

------------------------------------------------------------------------

## 🔑 Variables

`variables.tf` example:

``` hcl
variable "ssh_authorized_keys" {
  description = "List of SSH public keys to inject into the LXC container"
  type        = list(string)
}
```

Export via environment variable:

``` bash
export TF_VAR_ssh_authorized_keys='["ssh-ed25519 AAAA..."]'
```

------------------------------------------------------------------------

## 🧪 Post-Deployment Checks

### 1. SSH into a container

``` bash
ssh root@<container-ip>
```

### 2. Validate resources in Proxmox

-   CPU
-   RAM
-   Disk
-   Tags
-   Description
-   Network configuration

------------------------------------------------------------------------

## 📚 References

-   Proxmox Terraform Provider: https://registry.terraform.io/providers/bpg/proxmox/latest
-   Cloudflare R2: https://developers.cloudflare.com/r2
-   LXC Templates: https://pve.proxmox.com/wiki/Linux_Container
-   Custom LXC Terraform Module: https://github.com/Brsalcedom/tf-modules
-   Project Repository: https://github.com/Brsalcedom/homelab-iac

