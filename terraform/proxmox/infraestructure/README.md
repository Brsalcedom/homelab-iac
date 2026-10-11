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

#### ⚠️ Certificate error during install (`SSL certificate problem: self-signed certificate`)

The install script first resolves the `stable` channel against
`update.k3s.io`. If something in the network path (router/firewall) breaks
that specific connection, you get a `self-signed certificate` error even
though GitHub and `get.k3s.io` work fine. Skip the channel lookup entirely
by pinning the version explicitly:

```bash
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION="v1.37.1+k3s1" INSTALL_K3S_EXEC="--disable traefik --disable-network-policy --disable-kube-proxy --flannel-backend=none --node-name=hyperion" sh -
```

Check the latest available version at the
[k3s releases page](https://github.com/k3s-io/k3s/releases) before
installing.

#### Starting over

To fully remove K3s from a node and reinstall from scratch:

```bash
sudo /usr/local/bin/k3s-uninstall.sh
```

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

### 3. Firewall access to the Kubernetes API

The K3s API server listens on TCP port `6443` on the server node
(`192.168.10.201`). To use `kubectl` from the LAN, allow this port only
from trusted internal networks on the server's firewall. For the current
network, run these commands on `hyperion-01`:

```bash
sudo firewall-cmd --permanent --zone=public --add-rich-rule='rule family=ipv4 source address=192.168.10.0/24 port port=6443 protocol=tcp accept'
sudo firewall-cmd --permanent --zone=public --add-rich-rule='rule family=ipv4 source address=192.168.20.0/24 port port=6443 protocol=tcp accept'
sudo firewall-cmd --reload
sudo firewall-cmd --zone=public --list-rich-rules
```

Adjust the source CIDRs to match the trusted networks that need cluster
access. Avoid opening `6443/tcp` to all sources. Verify connectivity from
the client before running `kubectl`:

```powershell
Test-NetConnection 192.168.10.201 -Port 6443
```

The kubeconfig's API endpoint must also be reachable from the client; use
`192.168.10.201:6443`, not `127.0.0.1`.

### 4. Environment Variables for Cloudflare R2

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
