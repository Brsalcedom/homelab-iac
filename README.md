# 🏠 homelab-iac

Infraestructura como código para mi laboratorio personal en casa, gestionado con Terraform, K3s, GitOps y más.

[![Terraform](https://img.shields.io/badge/IaC-Terraform-623CE4?logo=terraform)](https://www.terraform.io/)
[![Kubernetes](https://img.shields.io/badge/K3s-Kubernetes-326CE5?logo=kubernetes)](https://k3s.io/)
[![FluxCD](https://img.shields.io/badge/GitOps-FluxCD-0064ff?logo=flux)](https://fluxcd.io/)
[![ArgoCD](https://img.shields.io/badge/GitOps-ArgoCD-d63aff?logo=argo)](https://argo-cd.readthedocs.io/)
[![Cloudflare](https://img.shields.io/badge/DNS-Cloudflare-F38020?logo=cloudflare)](https://cloudflare.com/)
[![License](https://img.shields.io/badge/Licencia-Personal-informational)]()

</div>

---

## 📖 Descripción

Este repositorio define toda la infraestructura de mi homelab de forma declarativa utilizando Terraform, Packer, GitOps y Kubernetes (`k3s`) sobre Proxmox. Mi objetivo es mantener un entorno autosustentable, reproducible y seguro que me permita:

- Automatizar todo el ciclo de vida de la infraestructura.
- Experimentar con nuevas herramientas DevOps y de seguridad.
- Desplegar servicios personales autogestionados.
- Aprender buenas prácticas de arquitectura, automatización y observabilidad.

---

## 🧱 Componentes Principales

| Categoría         | Tecnologías                                                                          |
|-------------------|---------------------------------------------------------------------------------------|
| **Orquestación**  | [K3s](https://k3s.io), [Cilium](https://cilium.io), [Linkerd](https://linkerd.io)     |
| **GitOps**        | [ArgoCD](https://argo-cd.readthedocs.io), [FluxCD](https://fluxcd.io)                |
| **Infraestructura**| [Terraform](https://www.terraform.io), [OpenTofu](https://opentofu.org), [Packer](https://www.packer.io) |
| **Almacenamiento**| [Rook + Ceph](https://rook.io), [Longhorn](https://longhorn.io)                      |
| **Certificados**  | [cert-manager](https://cert-manager.io), [Cloudflare DNS-01](https://developers.cloudflare.com/) |
| **Observabilidad**| [Prometheus](https://prometheus.io), [Grafana](https://grafana.com), [Loki](https://grafana.com/oss/loki) |
| **Red**           | [Cilium LB](https://docs.cilium.io), [kube-vip](https://kube-vip.io)                 |

---

## 📂 Estructura

```bash
homelab-iac/
├── k8s/         # Kubernetes modular por nodo (Hyperion / Cronos)
├── packer/      # Imágenes base para VM
└── proxmox/     # Código para provisionamiento de VMs
```
Consulta [`k8s/README.md`](./k8s/README.md) para ver los stacks y configuración de cada nodo de kubernetes.

---

## 🛠️ Requisitos

- Terraform ≥ 1.9.0
- Kubeconfig por nodo
- Dominio público para generar certificados válidos
- Token de API de Cloudflare
- Helm, Kubectl, Git

---

## 🙋 Autor

Bryan Salcedo — [https://cervant.net](https://cervant.net)