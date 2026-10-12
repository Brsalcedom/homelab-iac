---
title: Environment variables
description: Variables each Terraform configuration and the docs workflow expect.
sidebar:
  order: 3
---

In CI, most of these come from Bitwarden Secrets Manager through `bitwarden/sm-action`, using the `BW_TOKEN` repository secret.

## Shared: R2 state backend

All Terraform configurations under `terraform/` store state in the `homelab-tfstate` R2 bucket through the S3 backend.

| Variable | Value |
|----------|-------|
| `AWS_ACCESS_KEY_ID` | R2 access key |
| `AWS_SECRET_ACCESS_KEY` | R2 secret key |

## Proxmox VMs

`terraform/proxmox/vm`

| Variable | Value |
|----------|-------|
| `PROXMOX_VE_ENDPOINT` | `https://<proxmox-ip>:8006/api2/json` |
| `PROXMOX_VE_API_TOKEN` | `terraform@pve!iac=<TOKEN_SECRET>` |
| `PROXMOX_VE_SSH_USERNAME` | `root` |
| `PROXMOX_VE_SSH_PRIVATE_KEY` | Private key authorized on the node, for snippet uploads |
| `TF_VAR_ssh_authorized_keys` | JSON list of public keys for the VMs, e.g. `'["ssh-ed25519 AAAA..."]'` |

## Proxmox LXC

`terraform/proxmox/lxc`

| Variable | Value |
|----------|-------|
| `PROXMOX_VE_ENDPOINT` | `https://<proxmox-ip>:8006/api2/json` |
| `PROXMOX_VE_API_TOKEN` | `terraform@pve!iac=<TOKEN_SECRET>` |
| `TF_VAR_ssh_authorized_keys` | JSON list of public keys for the containers |
| `TF_VAR_node_name` | Target node (optional, default `prox`) |

## Hyperion

`terraform/proxmox/infraestructure/hyperion`

| Variable | Value |
|----------|-------|
| `KUBE_CONFIG_PATH` | Path to the Hyperion kubeconfig (API at `192.168.10.201:6443`). The `kubernetes` and `helm` providers are configured empty and read this variable, not `KUBECONFIG`. |
| `KUBECONFIG` | Same path, for `kubectl` in the bootstrap task |
| `CLOUDFLARE_API_TOKEN` | Cloudflare token with **Zone → DNS → Edit** and **Zone → Zone → Read** on `cervant.net`. The bootstrap task stores it as the `cloudflare-api-token` secret for cert-manager DNS-01. |
| `INFISICAL_API_TOKEN` | Infisical service token, stored as the `infisical-service-token` secret for the Infisical operator |
| `INFISICAL_ENCRYPTION_KEY` | Root encryption key of the self-hosted Infisical server (`openssl rand -hex 16`), stored in the `infisical-secrets` secret. **Losing it makes every secret in Infisical unreadable**, so it must never change. |
| `INFISICAL_AUTH_SECRET` | JWT signing secret of the self-hosted Infisical server (`openssl rand -base64 32`), stored in the `infisical-secrets` secret |

The bootstrap task (`.github/tasks/hyperion-bootstrap.yml`) reads `CLOUDFLARE_API_TOKEN`, `INFISICAL_API_TOKEN`, `INFISICAL_ENCRYPTION_KEY`, `INFISICAL_AUTH_SECRET` and `KUBECONFIG` from a `.env` file. CI writes it in `terraform/proxmox/infraestructure/hyperion` before running the task.

## Docs workflow

Bitwarden secrets used by `.github/workflows/docs.yaml`:

| Output | Value |
|--------|-------|
| `CLOUDFLARE_WORKERS_API_TOKEN` | Token with the **Edit Cloudflare Workers** permissions, passed to wrangler as `CLOUDFLARE_API_TOKEN` |
| `CLOUDFLARE_ACCOUNT_ID` | Cloudflare account ID |

The GHCR push uses the built-in `GITHUB_TOKEN`.

## Setting variables

Bash:

```bash
export PROXMOX_VE_ENDPOINT="https://<proxmox-ip>:8006/api2/json"
```

PowerShell:

```powershell
$env:PROXMOX_VE_ENDPOINT="https://<proxmox-ip>:8006/api2/json"
```
