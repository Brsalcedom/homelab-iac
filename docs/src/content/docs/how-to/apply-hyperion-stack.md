---
title: Apply the Hyperion stack
description: Install Cilium, cert-manager, the shared Gateway and ArgoCD on Hyperion with OpenTofu.
sidebar:
  order: 5
---

`terraform/proxmox/infraestructure/hyperion` installs the platform layer of the cluster: Cilium, cert-manager with a Cloudflare `ClusterIssuer`, the shared Gateway with a wildcard certificate, and ArgoCD with the `homelab` project and the root app-of-apps.

:::caution[Validated on K3s only]
This stack is tested only on K3s. On another distribution, see [What the stack expects from K3s](/explanation/clusters/#what-the-stack-expects-from-k3s) first.
:::

## Prerequisites

- [K3s is installed](/how-to/install-k3s-hyperion/), including the firewalld rules for the pod network and for `80/tcp` and `443/tcp`.
- The variables in [Environment variables: Hyperion](/reference/environment-variables/#hyperion) and the R2 credentials are set.

## Apply

Through CI: merge changes under `terraform/proxmox/infraestructure/hyperion` to `main`. The [`Tofu :: k8s hyperion`](/reference/ci-workflows/) workflow runs the bootstrap task, then plans and applies.

From your workstation, run the same two steps. The bootstrap task installs the cert-manager and ArgoCD CRDs and creates the `cloudflare-api-token`, `infisical-service-token` and `infisical-secrets` secrets. It must run first, because the plan needs those CRDs to exist.

```bash
cd terraform/proxmox/infraestructure/hyperion
export GITHUB_WORKSPACE="$(git rev-parse --show-toplevel)"  # the task resolves paths from it
task --taskfile "$GITHUB_WORKSPACE/.github/tasks/hyperion-bootstrap.yml"
tofu init
tofu apply
```

The apply waits 120 seconds after Cilium is installed so the CNI is ready before the other resources. The Gateway API CRDs are already there, because K3s installs them.

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
