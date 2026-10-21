---
title: "Clusters: Hyperion and Cronos"
description: Why there are two Kubernetes clusters with different stacks, and why Hyperion replaces the K3s defaults.
sidebar:
  order: 2
---

The homelab plans two K3s clusters with deliberately different stacks. Hyperion is for services used every day; Cronos is for learning alternatives without risking them.

## Hyperion: the stable cluster

Hyperion favors stability, security and observability. Its stack:

| Area | Choice |
|------|--------|
| CNI and mesh | Cilium |
| Gateway API | Cilium's built-in controller |
| GitOps | ArgoCD |
| Certificates | cert-manager + Cloudflare DNS-01 |
| LoadBalancer | K3s ServiceLB (node IP) |
| Secrets | Self-hosted Infisical + Kubernetes operator (Kubernetes Auth) |
| Policy engine | Kyverno |
| Storage | Rook + Ceph (planned) |
| Observability | Prometheus, Grafana, Loki, Alloy, blackbox_exporter |

### Why K3s runs without Traefik, Flannel and kube-proxy

K3s ships with Flannel, kube-proxy, a network policy controller and Traefik. Cilium does all of those jobs with eBPF, so Hyperion turns them off (`--flannel-backend=none --disable-kube-proxy --disable-network-policy --disable traefik`). Running both would mean two components fighting over the same packets.

One consequence: a fresh node has no networking until Cilium is installed. That is why Cilium is the first thing the Hyperion OpenTofu stack installs, followed by a 120-second wait.

### What the stack expects from K3s

The Hyperion stack is validated only on K3s (`v1.37.1+k3s1` on Rocky Linux 10.2). It assumes K3s in these places, and each would need changes on another distribution:

- **Gateway API CRDs.** K3s installs them through its bundled `gateway-api-crd` chart. The bootstrap kustomization (`crds/`) does not include them, so on another distribution nothing would install them.
- **API server address.** Cilium uses `k8sServiceHost=127.0.0.1` and `k8sServicePort=6443`, which matches a K3s server node where the API server listens locally.
- **Install flags.** Flannel, kube-proxy, the network policy controller and Traefik are turned off with K3s flags (see [Install K3s on Hyperion](/how-to/install-k3s-hyperion/)).
- **LoadBalancer IP.** The Gateway's `LoadBalancer` Service gets the node IP from the K3s ServiceLB (`svclb-*` pods). Cilium's LB IPAM is not configured.
- **Service CIDR.** Pods reach the API at `10.43.0.1`, the first address of the K3s default service CIDR.

### Secrets: self-hosted Infisical, bootstrapped from Bitwarden

Hyperion runs its own Infisical (`infisical-server`), with PostgreSQL on CloudNativePG and Valkey as its queue and cache. Apps get their secrets through the Infisical operator, which authenticates with Kubernetes Auth: Infisical checks the operator's ServiceAccount token against the cluster API, so the cluster holds no long-lived Infisical credential.

Infisical can't hold its own root keys, so `ENCRYPTION_KEY` and `AUTH_SECRET` live in Bitwarden Secrets Manager. The bootstrap task copies them into the cluster, together with the Cloudflare token cert-manager needs before anything else runs. Everything else belongs in Infisical.

Valkey runs as a plain Deployment because no Valkey operator was stable yet ([#160](https://github.com/Brsalcedom/homelab-iac/issues/160)).

### One Gateway, one wildcard certificate

All apps share a single Gateway in the `cilium-gateway` namespace, with one wildcard certificate for `*.home.cervant.net`. Apps only add an `HTTPRoute`. This keeps certificate issuance to one DNS-01 challenge, works for internal-only hostnames that aren't reachable from the internet, and keeps per-app manifests small.

## Cronos: the experimental cluster

Cronos is planned. It uses the alternative for each area, so both approaches can be compared on similar workloads:

| Area | Choice |
|------|--------|
| CNI | Flannel (K3s default) |
| Service mesh | Linkerd |
| Gateway API | NGINX Gateway Fabric |
| GitOps | FluxCD |
| Certificates | cert-manager + Cloudflare DNS-01 |
| LoadBalancer | kube-vip |
| Secrets | Vault + External Secrets Operator |
| Policy engine | OPA Gatekeeper |
| Storage | Longhorn |
| Observability | Prometheus, Grafana, Loki (via FluxCD) |

## Roadmap

- Deploy Rook + Ceph on Hyperion.
- Back up Infisical's PostgreSQL to R2.
- Run Valkey through an operator once a stable one exists ([#160](https://github.com/Brsalcedom/homelab-iac/issues/160)).
- Build Cronos with FluxCD and Linkerd.
- Add observability and dashboards per cluster.
