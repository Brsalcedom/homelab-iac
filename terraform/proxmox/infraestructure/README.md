# ☸️ homelab-iac/terraform/proxmox/infraestructure

This directory contains the Infrastructure as Code for the Kubernetes (`k3s`) nodes that make up the homelab. Currently, **Hyperion** is configured as the stable node, managed through Terraform, and uses Cloudflare R2 as a remote backend for state.

---

## 🌐 Node Overview

### 🔹 Hyperion (stable environment)

Node oriented towards personal services for daily use. Its configuration seeks stability, security, and observability.

| Component      | Technology                                    | Status |
|----------------|-----------------------------------------------|--------|
| CNI + Mesh     | [Cilium](https://cilium.io)                   | ✅     |
| Gateway API    | Cilium native Gateway API controller          | ✅     |
| GitOps         | [ArgoCD](https://argo-cd.readthedocs.io)      | ✅     |
| Certificates   | [Cert-Manager](https://cert-manager.io) + Cloudflare DNS-01 | ✅     |
| LoadBalancer   | Cilium (eBPF)                                 | ✅     |
| Secrets        | [Infisical](https://infisical.com) + Kubernetes Operator | ✅     |
| Policy Engine  | [Kyverno](https://kyverno.io)                 | ✅     |
| Storage        | [Rook + Ceph](https://rook.io)                | 🔜     |
| Observability  | Prometheus, Grafana, Loki (via ArgoCD)        | 🔜     |


---

### 🔸 Cronos (experimental environment)

_Planned node for testing, new integrations, and hands-on learning of more advanced or alternative tools._

| Component      | Technology                                       | Status |
|----------------|--------------------------------------------------|--------|
| CNI            | Flannel (default `k3s`)                          | 🔜     |
| Service Mesh   | [Linkerd](https://linkerd.io)                    | 🔜     |
| Gateway API    | [NGINX Gateway Fabric](https://www.nginx.com)   | 🔜     |
| GitOps         | [FluxCD](https://fluxcd.io)                      | 🔜     |
| Certificates   | [Cert-Manager](https://cert-manager.io) + Cloudflare DNS-01 | 🔜     |
| LoadBalancer   | [kube-vip](https://kube-vip.io)                  | 🔜     |
| Secrets        | [Vault](https://www.vaultproject.io) + [External Secrets Operator](https://external-secrets.io) | 🔜     |
| Policy Engine  | [OPA Gatekeeper](https://open-policy-agent.github.io/gatekeeper) | 🔜     |
| Storage        | [Longhorn](https://longhorn.io)                 | 🔜     |
| Observability  | Prometheus, Grafana, Loki (via FluxCD)           | 🔜     |

---

## 📁 Structure

```bash
terraform/proxmox/infraestructure/
└── hyperion/          # Stable stack: ArgoCD, Cilium, Gateway API, Cert-Manager
    ├── argocd.tf      # ArgoCD configuration
    ├── certmanager.tf # Cert-Manager + ClusterIssuer Cloudflare
    ├── cilium.tf      # Cilium CNI with Gateway API
    ├── gateway.tf     # Gateway and HTTPRoute
    ├── backend.tf     # Remote backend on Cloudflare R2
    ├── providers.tf   # Providers: Helm, Kubectl, Kubernetes
    └── locals.tf      # Local variables
```

---

## ⚙️ How to Apply

```bash
cd terraform/proxmox/infraestructure/hyperion
terraform init
terraform apply
```

---

## 🐳 K3s Installation per Node

Each node has its own K3s configuration according to the stack it will use. Here are the commands used to install K3s in a customized way:

### 🔹 Hyperion

```bash
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable traefik --disable-network-policy --disable-kube-proxy --flannel-backend=none --node-name=hyperion" sh -
```

- Traefik, Flannel, and kube-proxy are disabled since **Cilium** will be used as CNI, gateway, and network infrastructure.

### 🔸 Cronos

_Pending implementation._

---

## 🔧 Requirements

### 1. Terraform

Recommended version: **1.9+**

### 2. Kubeconfig

Make sure you have access to the K3s cluster:

```bash
export KUBECONFIG=/path/to/hyperion-kubeconfig.yaml
```

### 3. Environment Variables for Cloudflare R2

```bash
export AWS_ACCESS_KEY_ID="<R2_ACCESS_KEY>"
export AWS_SECRET_ACCESS_KEY="<R2_SECRET_KEY>"
# Windows
$env:AWS_ACCESS_KEY_ID="<R2_ACCESS_KEY>"
$env:AWS_SECRET_ACCESS_KEY="<R2_SECRET_KEY>"
```

---

## 🚧 TODO

- [ ] Deploy `Rook + Ceph` on Hyperion
- [ ] Implement Cronos node with FluxCD and Linkerd
- [ ] Add observability and dashboards per node
