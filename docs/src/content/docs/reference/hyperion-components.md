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
| GitOps | [ArgoCD](https://argo-cd.readthedocs.io), login with Pocket ID, Dex disabled | `argocd.tf` | ✅ |

## Applications (ArgoCD)

Defined under `kubernetes/applications/argocd/`.

| Component | Technology | Status |
|-----------|------------|--------|
| Secrets | [Infisical](https://infisical.com) Kubernetes operator | ✅ |
| Secrets manager | Self-hosted [Infisical](https://infisical.com), PostgreSQL on CloudNativePG, Valkey | ✅ |
| Policy engine | [Kyverno](https://kyverno.io), no policies deployed yet | ✅ |
| PostgreSQL | [CloudNativePG](https://cloudnative-pg.io) | ✅ |
| Identity | [Pocket ID](https://pocket-id.org) | ✅ |
| Container registry | [zot](https://zotregistry.dev), htpasswd users from Infisical, no anonymous access | ✅ |
| Image updates | [ArgoCD Image Updater](https://argocd-image-updater.readthedocs.io) | ✅ |
| Docs | `homelab-docs` (this wiki) | ✅ |
| Metrics and dashboards | [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack): Prometheus, Grafana with Pocket ID, node-exporter, kube-state-metrics. No Alertmanager yet | ✅ |
| Logs | [Loki](https://grafana.com/oss/loki/) single binary, fed by [Alloy](https://grafana.com/oss/alloy-opentelemetry-collector/) | ✅ |
| Uptime probes | [blackbox_exporter](https://github.com/prometheus/blackbox_exporter) | ✅ |
| Storage | [Rook + Ceph](https://rook.io) | 🔜 |

## Shared resources

| Resource | Kind | Namespace | Notes |
|----------|------|-----------|-------|
| `cilium-gateway` | `Gateway` | `cilium-gateway` | Listeners `https` (443, TLS terminate) and `http` (80) for `*.home.cervant.net`; routes allowed from all namespaces |
| `wildcard-certificate` | `Certificate` | `cilium-gateway` | `*.home.cervant.net`, stored in secret `tls-cert` |
| `redirect-to-https` | `HTTPRoute` | `cilium-gateway` | 301 from `http` to `https` |
| `cloudflare-clusterissuer` | `ClusterIssuer` | (cluster) | ACME DNS-01, token from secret `cloudflare-api-token` |
| `infisical-secrets` | `Secret` | `infisical` | Infisical `ENCRYPTION_KEY` and `AUTH_SECRET`, created by the bootstrap task |
| `infisical-config` | `ConfigMap` | `infisical-operator-system` | Operator's global `hostAPI`: `http://infisical.infisical.svc.cluster.local:8080/api` |
| `infisical-auth` | `ServiceAccount` | `infisical-operator-system` | Identity every `InfisicalSecret` uses for Kubernetes Auth |
| `infisical-auth-token-reviewer` | `ClusterRoleBinding` | (cluster) | Binds `infisical-auth` to `system:auth-delegator`, so Infisical can review its tokens |
| `homelab` | `AppProject` | `argocd` | Project for every app |
| `root` | `Application` | `argocd` | App-of-apps over `kubernetes/applications/argocd`, `*application.yaml`; ignores `/spec/source/kustomize/images` on child Applications |

## Endpoints

| URL | Service |
|-----|---------|
| `https://argocd.home.cervant.net` | ArgoCD |
| `https://pocket.home.cervant.net` | Pocket ID |
| `https://infisical.home.cervant.net` | Infisical |
| `https://docs.home.cervant.net` | This wiki |
| `https://zot.home.cervant.net` | zot registry and UI |
| `https://grafana.home.cervant.net` | Grafana |

## K3s install flags

```text
--disable traefik --disable-network-policy --disable-kube-proxy --flannel-backend=none --node-name=hyperion
```

## Nodes

| Name | IP | Proxmox VM ID | vCPU | Memory | Disk |
|------|----|---------------|------|--------|------|
| `hyperion-01` | `192.168.10.201` | 201 | 2 | 10 GiB | 60 GB |

Hyperion is a single-node cluster. With 2 GiB the node stalls once ArgoCD syncs the applications. The apps without the monitoring stack use about 4.5 GiB, and the stack requests about 1.2 GiB more, so keep it at 10 GiB or more. The `local-path` volumes (Prometheus, Loki, zot) and the images all live on the root disk, since `local-path` doesn't reserve the size a PVC asks for.
