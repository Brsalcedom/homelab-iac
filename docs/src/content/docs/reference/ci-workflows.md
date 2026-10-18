---
title: CI workflows
description: GitHub Actions workflows in .github/workflows, their triggers and runners.
sidebar:
  order: 5
---

Jobs that reach the LAN run on the [self-hosted runner](/how-to/setup-github-runner/) inside the `brsalcedom/homelab-ci` image. Everything else runs on GitHub-hosted runners.

## Infrastructure

| Workflow | File | Trigger | Runner |
|----------|------|---------|--------|
| Tofu :: Proxmox VM | `tofu-proxmox-vm.yaml` | Push to `main` on `terraform/proxmox/vm/**`, manual | self-hosted |
| Tofu :: Proxmox LXC | `tofu-proxmox-lxc.yaml` | Push to `main` on `terraform/proxmox/lxc/**`, manual | self-hosted |
| Tofu :: k8s hyperion | `tofu-k8s-hyperion.yaml` | Push to `main` on `terraform/proxmox/infraestructure/hyperion**`, manual | self-hosted |
| Bootstrap :: LXC auth | `lxc-auth-bootstrap.yaml` | Manual | self-hosted |
| Bootstrap :: LXC monitoring | `lxc-monitoring-bootstrap.yaml` | Manual | self-hosted |
| IaC :: Security Report | `iac-security-report.yml` | Pull requests on `terraform/**`, `cloudflare/**`, manual | GitHub-hosted |

The `Tofu ::` workflows have two jobs: **Plan** uploads `tfplan` as an artifact and **Apply** applies it. Every apply job waits for the `tofu-infra` environment.

`Tofu :: k8s hyperion` also runs the bootstrap task before planning. Changes to `.github/tasks/` or to `kubernetes/applications/` don't trigger it; run it by hand when the bootstrap secrets need to be applied again.

## Docs

| Workflow | File | Trigger | Runner |
|----------|------|---------|--------|
| Docs | `docs.yaml` | Push to `main` on `docs/**` and `terraform/**/*.tf`, pull requests on `docs/**`, manual | GitHub-hosted |

Jobs:

1. **Build**: runs terraform-docs into the reference pages, then `astro build`, and uploads `dist/` as an artifact.
2. **Cloudflare**: `wrangler deploy` of `dist/` to `docs.cervant.net`, with credentials from Bitwarden. Only on `main`.
3. **Image**: builds the nginx image with `dist/` and pushes `ghcr.io/brsalcedom/homelab-docs:sha-<commit>` and `:latest`. Only on `main`.

ArgoCD Image Updater picks up the new `:latest` digest and rolls out `docs.home.cervant.net`; the workflow doesn't touch the cluster.

On pull requests only the build runs.

## Repository housekeeping

| Workflow | File | Trigger |
|----------|------|---------|
| release-please | `release-please.yaml` | Push to `main` |
| Validate PR Title | `pr-title-check.yaml` | Pull requests (Conventional Commits) |
| PR assignment | `pr-auto-assign.yaml` | Pull requests |
| Label Sync | `label-sync.yaml` | `.github/labels.yml` changes, daily, pull requests |
