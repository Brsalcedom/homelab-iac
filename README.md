# 🏠 homelab-iac

Infrastructure as Code for my personal home lab, managed with Terraform, K3s, GitOps, and more.

[![Terraform](https://img.shields.io/badge/IaC-Terraform-623CE4?logo=terraform)](https://www.terraform.io/)
[![Kubernetes](https://img.shields.io/badge/K3s-Kubernetes-326CE5?logo=kubernetes)](https://k3s.io/)
[![FluxCD](https://img.shields.io/badge/GitOps-FluxCD-0064ff?logo=flux)](https://fluxcd.io/)
[![ArgoCD](https://img.shields.io/badge/GitOps-ArgoCD-d63aff?logo=argo)](https://argo-cd.readthedocs.io/)
[![Cloudflare](https://img.shields.io/badge/DNS-Cloudflare-F38020?logo=cloudflare)](https://cloudflare.com/)
[![License](https://img.shields.io/badge/License-Personal-informational)]()

---

## 📚 Documentation

The full documentation lives in [`docs/`](./docs) and is published at **[docs.cervant.net](https://docs.cervant.net)** (internally at `docs.home.cervant.net`).

| Start here | |
|---|---|
| [Getting started](https://docs.cervant.net/tutorials/getting-started/) | From a fresh Proxmox node to a VM managed by OpenTofu |
| [How-to guides](https://docs.cervant.net/how-to/deploy-vms/) | VMs, LXC containers, K3s, ArgoCD apps, the CI runner |
| [Reference](https://docs.cervant.net/reference/repository-layout/) | Layout, Proxmox permissions, environment variables, workflows |
| [Architecture](https://docs.cervant.net/explanation/architecture/) | How the layers fit together and why |

Agents can read [`llms.txt`](https://docs.cervant.net/llms.txt) or [`llms-full.txt`](https://docs.cervant.net/llms-full.txt).

---

## 📖 Description

This repository defines my homelab infrastructure declaratively with OpenTofu/Terraform, GitOps and Kubernetes (`k3s`) on Proxmox. The goal is a self-sustaining, reproducible and secure environment to automate the infrastructure lifecycle, experiment with DevOps and security tools, and host personal services.

---

## 📂 Structure

```bash
homelab-iac/
├── .github/                    # CI/CD workflows, labels and configuration
├── cloudflare/                 # Terraform for Cloudflare R2
├── docker/                     # Compose and Swarm stacks
├── docs/                       # Wiki (Starlight)
├── kubernetes/applications/
│   └── argocd/                 # Apps managed by ArgoCD on Hyperion
└── terraform/proxmox/
    ├── infraestructure/hyperion/  # K3s platform: Cilium, cert-manager, Gateway, ArgoCD
    ├── lxc/                    # LXC containers
    └── vm/                     # Virtual machines
```

---

## 🙋 Author

Bryan Salcedo — [https://cervant.net](https://cervant.net)