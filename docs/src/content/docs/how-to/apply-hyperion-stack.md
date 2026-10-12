---
title: Apply the Hyperion stack
description: Install Cilium, cert-manager, the shared Gateway and ArgoCD on Hyperion with OpenTofu.
sidebar:
  order: 5
---

`terraform/proxmox/infraestructure/hyperion` installs the platform layer of the cluster: Cilium, cert-manager with a Cloudflare `ClusterIssuer`, the shared Gateway with a wildcard certificate, and ArgoCD with the `homelab` project and the root app-of-apps.

## Prerequisites

- [K3s is installed](/how-to/install-k3s-hyperion/) and `KUBECONFIG` points to Hyperion.
- R2 credentials are exported (see [Environment variables](/reference/environment-variables/#hyperion)).
- A secret named `cloudflare-api-token` with the key `api-token` exists in the `cert-manager` namespace, for DNS-01 challenges.

## Apply

Through CI: merge changes under `terraform/proxmox/infraestructure/hyperion` to `main`. The [`Tofu :: k8s hyperion`](/reference/ci-workflows/) workflow plans and applies.

From your workstation:

```bash
cd terraform/proxmox/infraestructure/hyperion
tofu init
tofu apply
```

The apply waits 120 seconds after Cilium is installed so the CNI and the Gateway API CRDs are ready before the other resources.

## Check the result

```bash
kubectl get pods -A
kubectl get gateway -n cilium-gateway
kubectl get certificate -n cilium-gateway
```

`wildcard-certificate` should be `Ready`, and ArgoCD should answer at `https://argocd.home.cervant.net`.

## Change chart versions

Chart versions are pinned in `locals.tf` (`cilium_chart_version`, `argocd_chart_version`, `cert_manager_chart_version`). Renovate opens pull requests for them.

See [Hyperion components](/reference/hyperion-components/) and [Terraform: Hyperion](/reference/terraform-hyperion/).
