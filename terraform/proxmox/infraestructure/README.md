# ☸️ homelab-iac/terraform/proxmox/infraestructure

Este directorio contiene la infraestructura como código de los nodos Kubernetes (`k3s`) que componen el homelab. Actualmente está configurado **Hyperion** como nodo estable, gestionado mediante Terraform, y utiliza Cloudflare R2 como backend remoto para el estado.

---

## 🌐 Descripción general de los nodos

### 🔹 Hyperion (entorno estable)

Nodo orientado a servicios personales de uso cotidiano. Su configuración busca estabilidad, seguridad y observabilidad.

| Componente     | Tecnología                                    | Estado |
|----------------|-----------------------------------------------|--------|
| CNI + Mesh     | [Cilium](https://cilium.io)                   | ✅     |
| Gateway API    | Controlador Gateway API nativo de Cilium      | ✅     |
| GitOps         | [ArgoCD](https://argo-cd.readthedocs.io)      | ✅     |
| Certificados   | [Cert-Manager](https://cert-manager.io) + Cloudflare DNS-01 | ✅     |
| LoadBalancer   | Cilium (eBPF)                                 | ✅     |
| Almacenamiento | [Rook + Ceph](https://rook.io)                | 🔜     |
| Observabilidad | Prometheus, Grafana, Loki (vía ArgoCD)        | 🔜     |


---

### 🔸 Cronos (entorno experimental)

_Nodo planificado para pruebas, nuevas integraciones y aprendizaje práctico de herramientas más avanzadas o alternativas._

| Componente     | Tecnología                                       | Estado |
|----------------|--------------------------------------------------|--------|
| CNI            | Flannel (default de `k3s`)                       | 🔜     |
| Service Mesh   | [Linkerd](https://linkerd.io)                    | 🔜     |
| Gateway API    | [NGINX Gateway Fabric](https://www.nginx.com)   | 🔜     |
| GitOps         | [FluxCD](https://fluxcd.io)                      | 🔜     |
| Certificados   | [Cert-Manager](https://cert-manager.io) + Cloudflare DNS-01 | 🔜     |
| LoadBalancer   | [kube-vip](https://kube-vip.io)                  | 🔜     |
| Almacenamiento | [Longhorn](https://longhorn.io)                 | 🔜     |
| Observabilidad | Prometheus, Grafana, Loki (vía FluxCD)           | 🔜     |

---

## 📁 Estructura

```bash
terraform/proxmox/infraestructure/
└── hyperion/          # Stack estable: ArgoCD, Cilium, Gateway API, Cert-Manager
    ├── argocd.tf      # Configuración de ArgoCD
    ├── certmanager.tf # Cert-Manager + ClusterIssuer Cloudflare
    ├── cilium.tf      # CNI Cilium con Gateway API
    ├── gateway.tf     # Gateway y HTTPRoute
    ├── backend.tf     # Backend remoto en Cloudflare R2
    ├── providers.tf   # Providers: Helm, Kubectl, Kubernetes
    └── locals.tf      # Variables locales
```

---

## ⚙️ Cómo aplicar

```bash
cd terraform/proxmox/infraestructure/hyperion
terraform init
terraform apply
```

---

## 🐳 Instalación de K3s por nodo

Cada nodo tiene su propia configuración de K3s según el stack que usará. Aquí se muestran los comandos usados para instalar K3s de forma personalizada:

### 🔹 Hyperion

```bash
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable traefik --disable-network-policy --disable-kube-proxy --flannel-backend=none --node-name=hyperion" sh -
```

- Se desactiva Traefik, Flannel y kube-proxy ya que se utilizará **Cilium** como CNI, gateway e infraestructura de red.

### 🔸 Cronos

_Pendiente de implementación._

---

## 🔧 Requisitos

### 1. Terraform

Versión recomendada: **1.9+**

### 2. Kubeconfig

Asegúrate de tener acceso al cluster K3s:

```bash
export KUBECONFIG=/path/to/hyperion-kubeconfig.yaml
```

### 3. Variables de entorno para Cloudflare R2

```bash
export AWS_ACCESS_KEY_ID="<R2_ACCESS_KEY>"
export AWS_SECRET_ACCESS_KEY="<R2_SECRET_KEY>"
# Windows
$env:AWS_ACCESS_KEY_ID="<R2_ACCESS_KEY>"
$env:AWS_SECRET_ACCESS_KEY="<R2_SECRET_KEY>"
```

---

## 🚧 TODO

- [ ] Desplegar `Rook + Ceph` en Hyperion
- [ ] Implementar nodo Cronos con FluxCD y Linkerd
- [ ] Agregar observabilidad y dashboards por nodo
