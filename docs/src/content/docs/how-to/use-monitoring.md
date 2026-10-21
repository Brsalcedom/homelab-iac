---
title: Use the monitoring stack
description: Log in to Grafana, query metrics and logs, and add scrape targets and uptime probes on Hyperion.
sidebar:
  order: 13
---

Monitoring runs on Hyperion, in the `monitoring` namespace, as four ArgoCD apps:

| App | Runs | Values |
|-----|------|--------|
| `kube-prometheus-stack` | Prometheus, Grafana, Prometheus Operator, node-exporter, kube-state-metrics | `kube-prometheus-stack/values.yaml`, plus `manifests/` with the `HTTPRoute` and the `InfisicalSecret` |
| `loki` | Loki, single binary | `loki/values.yaml` |
| `alloy` | Alloy DaemonSet that ships pod logs and cluster events to Loki | `alloy/values.yaml` |
| `blackbox-exporter` | HTTP and DNS probes | `blackbox-exporter/values.yaml` |

Grafana is at `https://grafana.home.cervant.net`. Prometheus and Loki aren't exposed; query them from Grafana's **Explore**, or port-forward:

```bash
kubectl -n monitoring port-forward svc/kube-prometheus-stack-prometheus 9090
```

| Data | Retention | Volume |
|------|-----------|--------|
| Metrics | 7 days, or 3 GB | 20Gi `local-path` |
| Logs | 14 days | 20Gi `local-path` |

:::caution[Disk, backups and alerts]
`local-path` doesn't reserve the size a PVC asks for: every volume shares Hyperion's 28 GiB root disk, which also holds the images. Prometheus writes about 600 MB a day, so `retentionSize` is what keeps it from filling the disk; raise it only after growing the disk. The volumes have no backups. Alertmanager is disabled: the default rules show up as firing in Grafana and Prometheus, but nothing sends notifications yet.
:::

Grafana has no volume. Datasources and dashboards come from Git, and users are recreated on their next login, so dashboards created in the UI are lost when the pod restarts. Export them as JSON and add them to the values.

## Set up (once)

1. In Pocket ID, create the `grafana_admins` group and add yourself to it.
2. Create an OIDC client `grafana`, with callback URL `https://grafana.home.cervant.net/login/generic_oauth` and `grafana_admins` as allowed group.
3. Add these secrets to Infisical (`hyperion`, `prod`, `/`):

   | Secret | Value |
   |--------|-------|
   | `grafana_admin_password` | Password for the local `admin` user |
   | `grafana_oidc_client_id` | Client ID of `grafana` |
   | `grafana_oidc_client_secret` | Client secret of `grafana` |

4. Merge. ArgoCD syncs the apps, and the Pi-hole sync adds `grafana.home.cervant.net`.

### Access

| Who | Role | How |
|-----|------|-----|
| Members of `grafana_admins` | Admin | **Sign in with Pocket ID** |
| `admin` | Admin | Break-glass if Pocket ID is down. Password in Infisical |
| Anyone else in Pocket ID | None | `role_attribute_strict` rejects the login |

## Dashboards

| Folder | Source |
|--------|--------|
| `Homelab` | **Homelab Overview**: endpoint status and certificate expiry, node CPU, memory and disk, pods and restarts, ArgoCD apps, and error logs |
| General | kube-prometheus-stack's Kubernetes, node (Linux only) and Prometheus dashboards |
| `grafana.com` | Node Exporter Full (1860) and Blackbox Exporter (13659), downloaded when Grafana starts |

### Add a dashboard of your own

Dashboards of our own are JSON files in `kube-prometheus-stack/manifests/dashboards/`. `configMapGenerator` in `manifests/kustomization.yaml` turns each one into a ConfigMap labeled `grafana_dashboard: "1"`, and the Grafana sidecar loads it into the folder named by its `grafana_folder` annotation.

1. Build the dashboard in Grafana. It can't be saved over a provisioned one, so use **Save as** or start a new one.
2. **Export → Export as JSON**, with **Export for sharing externally** off, so datasources stay as the `prometheus` and `loki` UIDs.
3. Save it under `manifests/dashboards/` and add it to `configMapGenerator`:

   ```yaml
   - name: grafana-dashboard-<name>
     files:
       - dashboards/<name>.json
     options:
       disableNameSuffixHash: true
       labels:
         grafana_dashboard: "1"
       annotations:
         grafana_folder: Homelab
   ```

To add a dashboard from grafana.com instead, add it under `grafana.dashboards.grafana-com` in the values, with its `gnetId` and a pinned `revision`.

## Logs

Alloy reads pod logs through the Kubernetes API and adds these labels:

| Label | From |
|-------|------|
| `namespace`, `pod`, `container`, `node` | The pod |
| `app` | The pod's `app.kubernetes.io/name` label, when set |
| `job="kubernetes-events"` | Cluster events |

```logql
{namespace="argocd", container="argocd-server"} |= "error"
{job="kubernetes-events"} |= "Warning"
```

Only Hyperion's pods are collected. The LXC hosts and Swarm aren't, and Dozzle is still the way to read their container logs.

## Scrape an app

Prometheus selects every `ServiceMonitor`, `PodMonitor`, `Probe`, `ScrapeConfig` and `PrometheusRule` in the cluster, not only the ones labeled with the release. Most charts create a `ServiceMonitor` when you set `serviceMonitor.enabled: true` (or `metrics.serviceMonitor.enabled`); for an app without one, add a `ServiceMonitor` to its `manifests/`.

ArgoCD is installed by OpenTofu before the Prometheus Operator CRDs exist, so its chart doesn't create monitors. `kube-prometheus-stack/manifests/podmonitor-argocd.yaml` scrapes the `metrics` port of its pods instead, which provides `argocd_app_info` and the rest of ArgoCD's metrics.

## Add an uptime probe

Add an entry to `serviceMonitor.targets` in `blackbox-exporter/values.yaml`:

```yaml
- name: my-app
  url: https://my-app.home.cervant.net
```

| Module | Checks |
|--------|--------|
| `http_2xx` (default) | 2xx response, following redirects, with a valid certificate |
| `http_2xx_insecure` | The same without verifying the certificate, for self-signed ones such as Proxmox |
| `dns_home` | The target DNS server resolves `hyperion-01.home.cervant.net` to `192.168.10.201` |

`probe_success` is `1` while a target is up, and `probe_ssl_earliest_cert_expiry` holds its certificate's expiry. The Blackbox Exporter dashboard shows both.

## Check it

```bash
kubectl -n monitoring get pods
kubectl -n monitoring get secret grafana-secrets
kubectl -n monitoring get servicemonitors
```

| Symptom | Cause |
|---------|-------|
| `grafana` stuck in `CreateContainerConfigError` | `grafana-secrets` is missing: the Infisical secrets aren't there, or their names don't match |
| Pocket ID says `Invalid callback URL` | The callback in Pocket ID isn't exactly `https://grafana.home.cervant.net/login/generic_oauth` |
| Pocket ID login succeeds but Grafana rejects it | Your groups don't include `grafana_admins`, so `role_attribute_path` returns no role. Log out of Pocket ID and back in after changing a membership |
| A target is missing from **Status → Targets** in Prometheus | The `ServiceMonitor` selects no Service: check its `selector` and port name against the Service |
| No logs in Explore | `kubectl -n monitoring logs ds/alloy`; Alloy logs push errors when Loki is down |
