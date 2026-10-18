---
title: Repository layout
description: What each top-level directory of homelab-iac contains.
sidebar:
  order: 1
---

```text
homelab-iac/
├── .github/                    # Workflows, labels, labeler and PR template
│   └── tasks/                  # Bootstrap Taskfiles (go-task) run by CI
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
| `kyverno` | Policy engine. The policies in `kyverno/policies/` are not deployed yet: the app only uses that directory for its Helm values. |
| `netbird` | NetBird agent |
| `pocket-id` | OIDC identity provider |

### Application labels

Every `Application` carries these labels, so apps can be filtered in the ArgoCD UI and with `kubectl -l`:

| Label | Values | Meaning |
|-------|--------|---------|
| `tier` | `controllers`, `platform`, `apps` | Operators and cluster-wide controllers, shared platform services, or end-user apps |
| `domain` | `gitops`, `platform`, `security`, `networking`, `identity`, `docs` | Functional area |
| `source` | `helm`, `manifests`, `multi` | A Helm chart, a Kustomize directory, or several sources |
| `exposure` | `none`, `internal` | Whether the app has an `HTTPRoute` on `*.home.cervant.net` |
| `criticality` | `core`, `standard` | Whether other apps or daily use depend on it |
| `image-updates` | `enabled`, `disabled` | Whether ArgoCD Image Updater manages its images (an `ImageUpdater` resource) |

## Requirements

- OpenTofu or Terraform 1.9 or later
- A kubeconfig per cluster
- A public domain for valid certificates
- A Cloudflare API token
- Helm, kubectl, Git
- Node.js 22 or later, to work on these docs
