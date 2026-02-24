# 🏠 homelab-iac

Infrastructure as Code for my personal home lab, managed with Terraform, K3s, GitOps, and more.

[![Terraform](https://img.shields.io/badge/IaC-Terraform-623CE4?logo=terraform)](https://www.terraform.io/)
[![Kubernetes](https://img.shields.io/badge/K3s-Kubernetes-326CE5?logo=kubernetes)](https://k3s.io/)
[![FluxCD](https://img.shields.io/badge/GitOps-FluxCD-0064ff?logo=flux)](https://fluxcd.io/)
[![ArgoCD](https://img.shields.io/badge/GitOps-ArgoCD-d63aff?logo=argo)](https://argo-cd.readthedocs.io/)
[![Cloudflare](https://img.shields.io/badge/DNS-Cloudflare-F38020?logo=cloudflare)](https://cloudflare.com/)
[![License](https://img.shields.io/badge/License-Personal-informational)]()

</div>

---

## 📖 Description

This repository defines all my homelab infrastructure declaratively using Terraform, Packer, GitOps, and Kubernetes (`k3s`) on Proxmox. My goal is to maintain a self-sustaining, reproducible, and secure environment that allows me to:

- Automate the entire infrastructure lifecycle.
- Experiment with new DevOps and security tools.
- Deploy self-hosted personal services.
- Learn best practices in architecture, automation, and observability.

---

## 🧱 Main Components

| Category          | Technologies                                                                          |
|-------------------|---------------------------------------------------------------------------------------|
| **Orchestration** | [K3s](https://k3s.io), [Cilium](https://cilium.io), [Linkerd](https://linkerd.io)     |
| **GitOps**        | [ArgoCD](https://argo-cd.readthedocs.io), [FluxCD](https://fluxcd.io)                |
| **Infrastructure**| [Terraform](https://www.terraform.io), [OpenTofu](https://opentofu.org), [Packer](https://www.packer.io) |
| **Storage**       | [Rook + Ceph](https://rook.io), [Longhorn](https://longhorn.io)                      |
| **Certificates**  | [cert-manager](https://cert-manager.io), [Cloudflare DNS-01](https://developers.cloudflare.com/) |
| **Observability** | [Prometheus](https://prometheus.io), [Grafana](https://grafana.com), [Loki](https://grafana.com/oss/loki) |
| **Networking**    | [Cilium LB](https://docs.cilium.io), [kube-vip](https://kube-vip.io)                 |

---

## 📂 Structure

```bash
homelab-iac/
├── .github/                    # CI/CD workflows, labels and configuration
├── cloudflare/                 # Terraform for Cloudflare R2 and DNS
├── docker/                     # Compose and Swarm stacks
│   ├── compose/               # Docker Compose configs
│   └── swarm/                 # Docker Swarm stacks
├── kubernetes/                 # K8s application manifests
│   └── applications/
│       └── argocd/            # Apps managed by ArgoCD
├── packer/                     # Base VM images with Packer
└── terraform/                  # Infrastructure as Code
    └── proxmox/
        ├── infraestructure/   # K3s clusters (Hyperion)
        │   └── hyperion/      # Stable stack: Cilium, ArgoCD, Gateway API
        ├── lxc/               # LXC containers
        └── vm/                # Virtual machines
```

See [`terraform/proxmox/infraestructure/README.md`](./terraform/proxmox/infraestructure/README.md) for stacks and configuration details of each Kubernetes node.

---

## 🛠️ Requirements

- Terraform ≥ 1.9.0
- Kubeconfig per node
- Public domain for valid certificate generation
- Cloudflare API token
- Helm, Kubectl, Git

---

## 🙋 Author

Bryan Salcedo — [https://cervant.net](https://cervant.net)