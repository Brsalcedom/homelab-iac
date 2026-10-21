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
| Metrics | 15 days, or 18 GB | 20Gi `local-path` |
| Logs | 14 days | 20Gi `local-path` |

:::caution[No backups, no alerts]
Both volumes are `local-path` on the node, without backups. Alertmanager is disabled: the default rules show up as firing in Grafana and Prometheus, but nothing sends notifications yet.
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
| General | kube-prometheus-stack's Kubernetes, node and Prometheus dashboards |
| `grafana.com` | Node Exporter Full (1860) and Blackbox Exporter (13659), downloaded when Grafana starts |

To add a dashboard from grafana.com, add it under `grafana.dashboards.grafana-com` with its `gnetId` and a pinned `revision`. To add one of your own, put its JSON in a ConfigMap labeled `grafana_dashboard: "1"`; the Grafana sidecar loads it from any namespace.

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
