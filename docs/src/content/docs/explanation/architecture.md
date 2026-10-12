---
title: Architecture
description: How the layers of the homelab fit together, from Proxmox up to the apps.
sidebar:
  order: 1
---

The homelab is described declaratively in this repository and built in layers. Each layer is owned by one tool, and each tool hands off to the next.

```text
┌──────────────────────────────────────────────────────────────────┐
│ Apps on Hyperion            ArgoCD ← kubernetes/applications/    │
├──────────────────────────────────────────────────────────────────┤
│ K3s platform                OpenTofu ← terraform/.../hyperion    │
│ Cilium · Gateway API · cert-manager · ArgoCD                     │
├──────────────────────────────────────────────────────────────────┤
│ Guests                      OpenTofu ← terraform/proxmox/{vm,lxc}│
│ VMs (K3s nodes, hermes-agent) · LXC (Swarm, runner, DNS, auth…)  │
├──────────────────────────────────────────────────────────────────┤
│ Proxmox VE                  manual bootstrap (user, role, token) │
└──────────────────────────────────────────────────────────────────┘
        state: Cloudflare R2        DNS + certificates: Cloudflare
```

## Layers

**Proxmox VE.** The only manual layer: create the `terraform@pve` user and token, enable snippets, and build the VM template. Everything above is code.

**Guests.** OpenTofu creates VMs from a Rocky Linux cloud-init template and LXC containers from Debian templates. Each guest is an entry in a `locals.tf` map; shared settings live in `defaults`, so adding a machine is a few lines.

**K3s platform.** On the Hyperion VMs, K3s runs without its bundled networking. OpenTofu installs the pieces that must exist before GitOps can work: the CNI, the certificate issuer, the shared Gateway and ArgoCD itself.

**Apps.** ArgoCD takes over from there. The root app-of-apps watches `kubernetes/applications/argocd`, so adding an app is a pull request.

Some services still run outside Kubernetes, as Docker Compose on LXC hosts (`lxc-auth`, `lxc-monitoring`) or as Swarm stacks on `swarm-01`/`swarm-02`.

## Why split OpenTofu and ArgoCD

OpenTofu is good at creating things in order with explicit dependencies: Cilium has to run before anything can get an IP, and cert-manager has to run before the Gateway can get its certificate. ArgoCD is good at keeping many independent apps in sync with Git. The split puts the bootstrap order in OpenTofu and the day-to-day changes in ArgoCD.

## Network

| Range | Use |
|-------|-----|
| `192.168.10.0/24` | Server network: Proxmox guests, K3s nodes |
| `192.168.10.1` | Gateway |
| `192.168.10.150` | Pi-hole (internal DNS) |
| `*.home.cervant.net` | Internal services behind the Cilium Gateway |

## CI

Changes reach the infrastructure through GitHub Actions. Jobs that need the LAN run on a self-hosted runner in an LXC container, inside a container image with the tooling. Secrets come from Bitwarden Secrets Manager. See [CI workflows](/reference/ci-workflows/).
