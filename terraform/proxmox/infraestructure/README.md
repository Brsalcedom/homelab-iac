# ☸️ homelab-iac/terraform/proxomox/infraestructure

Este directorio contiene la infraestructura como código de los dos nodos Kubernetes (`k3s`) que componen el homelab: **Hyperion** y **Cronos**. Cada uno está configurado y gestionado de forma independiente mediante Terraform (compatible con futura migración a OpenTofu), y utiliza un stack distinto para cumplir roles diferentes: uno como entorno estable y otro como entorno experimental.

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

Nodo para pruebas, nuevas integraciones y aprendizaje práctico de herramientas más avanzadas o alternativas.

| Componente     | Tecnología                                       | Estado |
|----------------|--------------------------------------------------|--------|
| CNI            | Flannel (default de `k3s`)                       | ✅     |
| Service Mesh   | [Linkerd](https://linkerd.io)                    | ✅     |
| Gateway API    | [NGINX Gateway Fabric](https://www.nginx.com)   | ✅     |
| GitOps         | [FluxCD](https://fluxcd.io)                      | ✅     |
| Certificados   | [Cert-Manager](https://cert-manager.io) + Cloudflare DNS-01 | ✅     |
| LoadBalancer   | [kube-vip](https://kube-vip.io)                  | ✅     |
| Almacenamiento | [Longhorn](https://longhorn.io)                 | 🔜     |
| Observabilidad | Prometheus, Grafana, Loki (vía FluxCD)           | 🔜     |

---

## 📁 Estructura

```bash
k8s/
├── hyperion/   # Stack estable: ArgoCD, Cilium, Gateway API, Rook, etc.
└── cronos/     # Stack experimental: FluxCD, Linkerd, Longhorn, etc.
```

Cada subcarpeta contiene módulos Terraform independientes para su clúster. Los componentes como `cert-manager`, `GitOps`, `storage`, etc., están definidos modularmente en archivos `.tf`.

---

## ⚙️ Cómo aplicar

```bash
cd k8s/hyperion
terraform init
terraform apply -var-file="terraform.tfvars"

cd ../cronos
terraform init
terraform apply -var-file="terraform.tfvars"
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

_Comando pendiente de definir, dependerá de si se usará flannel por defecto o una configuración con kube-vip y Linkerd._

---


## 🚧 TODO

- [ ] Desplegar `Rook + Ceph` en Hyperion
- [ ] Desplegar `Longhorn` en Cronos
- [ ] Agregar observabilidad y dashboards por nodo
