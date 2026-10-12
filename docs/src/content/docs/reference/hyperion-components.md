---
title: Hyperion components
description: Components of the Hyperion K3s cluster, where each one is defined and its status.
sidebar:
  order: 4
---

## Platform (OpenTofu)

Installed by `terraform/proxmox/infraestructure/hyperion`. Chart versions are in `locals.tf`.

| Component | Technology | Defined in | Status |
|-----------|------------|------------|--------|
| CNI, kube-proxy replacement | [Cilium](https://cilium.io) (eBPF) | `cilium.tf` | ✅ |
| LoadBalancer | K3s ServiceLB (`svclb-*` pods), node IP `192.168.10.201` | Built into K3s | ✅ |
| Gateway API | Cilium Gateway API controller | `cilium.tf`, `gateway.tf` | ✅ |
| Certificates | [cert-manager](https://cert-manager.io) + Let's Encrypt DNS-01 on Cloudflare | `certmanager.tf` | ✅ |
| GitOps | [ArgoCD](https://argo-cd.readthedocs.io) | `argocd.tf` | ✅ |

## Applications (ArgoCD)

Defined under `kubernetes/applications/argocd/`.

| Component | Technology | Status |
|-----------|------------|--------|
| Secrets | [Infisical](https://infisical.com) Kubernetes operator | ✅ |
| Policy engine | [Kyverno](https://kyverno.io) | ✅ |
| PostgreSQL | [CloudNativePG](https://cloudnative-pg.io) | ✅ |
| Identity | [Pocket ID](https://pocket-id.org) | ✅ |
| Image updates | [ArgoCD Image Updater](https://argocd-image-updater.readthedocs.io) | ✅ |
| Docs | `homelab-docs` (this wiki) | ✅ |
| Storage | [Rook + Ceph](https://rook.io) | 🔜 |
| Observability | Prometheus, Grafana, Loki | 🔜 |

## Shared resources

| Resource | Kind | Namespace | Notes |
|----------|------|-----------|-------|
| `cilium-gateway` | `Gateway` | `cilium-gateway` | Listeners `https` (443, TLS terminate) and `http` (80) for `*.home.cervant.net`; routes allowed from all namespaces |
| `wildcard-certificate` | `Certificate` | `cilium-gateway` | `*.home.cervant.net`, stored in secret `tls-cert` |
| `redirect-to-https` | `HTTPRoute` | `cilium-gateway` | 301 from `http` to `https` |
| `cloudflare-clusterissuer` | `ClusterIssuer` | (cluster) | ACME DNS-01, token from secret `cloudflare-api-token` |
| `homelab` | `AppProject` | `argocd` | Project for every app |
| `root` | `Application` | `argocd` | App-of-apps over `kubernetes/applications/argocd`, `*application.yaml`; ignores `/spec/source/kustomize/images` on child Applications |

## Endpoints

| URL | Service |
|-----|---------|
| `https://argocd.home.cervant.net` | ArgoCD |
| `https://pocket.home.cervant.net` | Pocket ID |
| `https://docs.home.cervant.net` | This wiki |

## K3s install flags

```text
--disable traefik --disable-network-policy --disable-kube-proxy --flannel-backend=none --node-name=hyperion
```

## Nodes

| Name | IP | Proxmox VM ID | vCPU | Memory |
|------|----|---------------|------|--------|
| `hyperion-01` | `192.168.10.201` | 201 | 2 | 6 GiB |

Hyperion is a single-node cluster. With 2 GiB the node stalls once ArgoCD syncs the applications, so keep it at 6 GiB or more.
