---
title: Repository layout
description: What each top-level directory of homelab-iac contains.
sidebar:
  order: 1
---

```text
homelab-iac/
├── .github/                    # Workflows, labels, labeler and PR template
│   └── tasks/                  # Ansible-style bootstrap task files
├── cloudflare/                 # Terraform for Cloudflare (R2 state bucket)
├── docker/
│   ├── compose/                # Docker Compose stacks for LXC hosts (auth, monitoring)
│   └── swarm/                  # Docker Swarm stacks
├── docs/                       # This wiki (Starlight)
├── kubernetes/
│   └── applications/
│       └── argocd/             # Apps managed by ArgoCD on Hyperion
└── terraform/
    └── proxmox/
        ├── infraestructure/
        │   └── hyperion/       # Platform stack: Cilium, cert-manager, Gateway, ArgoCD
        ├── lxc/                # LXC containers
        └── vm/                 # QEMU virtual machines
```

## Terraform configurations

| Path | Manages | State key in R2 |
|------|---------|-----------------|
| `terraform/proxmox/vm` | QEMU VMs cloned from a cloud-init template | `proxmox/vm/terraform.tfstate` |
| `terraform/proxmox/lxc` | LXC containers | `proxmox/lxc/terraform.tfstate` |
| `terraform/proxmox/infraestructure/hyperion` | Helm releases and manifests on the Hyperion cluster | `k8s/infra/hyperion/terraform.tfstate` |
| `cloudflare` | The `homelab-tfstate` R2 bucket | local (no remote backend) |

## ArgoCD applications

Each directory under `kubernetes/applications/argocd/` holds one app: an `application.yaml` plus either Helm values or a `manifests/` Kustomize directory. The root app-of-apps (created in `argocd.tf`) syncs every `*application.yaml` file recursively.

| App | Purpose |
|-----|---------|
| `argocd-image-updater` | Updates app images from their registries (argocd write-back) |
| `cloudnative-pg` | PostgreSQL operator |
| `homelab-docs` | This wiki, served internally |
| `infisical` | Infisical secrets operator |
| `infisical-server` | Self-hosted Infisical server, with its PostgreSQL cluster and Valkey |
| `kyverno` | Policy engine and cluster policies |
| `netbird` | NetBird agent |
| `pocket-id` | OIDC identity provider |

## Requirements

- OpenTofu or Terraform 1.9 or later
- A kubeconfig per cluster
- A public domain for valid certificates
- A Cloudflare API token
- Helm, kubectl, Git
- Node.js 22 or later, to work on these docs
