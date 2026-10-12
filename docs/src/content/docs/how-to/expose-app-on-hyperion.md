---
title: Expose an app on Hyperion
description: Add an application to ArgoCD and publish it on *.home.cervant.net through the shared Cilium Gateway.
sidebar:
  order: 6
---

Every app on Hyperion follows the same pattern: an ArgoCD `Application` that points to a Kustomize directory, and an `HTTPRoute` attached to the shared `cilium-gateway`. TLS is already handled by the gateway's wildcard certificate, so you don't create a `Certificate` per app.

## 1. Create the directory

```text
kubernetes/applications/argocd/<app>/
├── application.yaml
└── manifests/
    ├── kustomization.yaml
    ├── namespace.yaml
    ├── deployment.yaml
    ├── service.yaml
    └── httproute.yaml
```

The root app-of-apps picks up every file named `*application.yaml` under `kubernetes/applications/argocd`, so nothing else needs to be registered.

## 2. Write the Application

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: <app>
  namespace: argocd
  annotations:
    argocd.argoproj.io/sync-wave: "2"
spec:
  project: homelab
  source:
    repoURL: https://github.com/Brsalcedom/homelab-iac.git
    targetRevision: main
    path: kubernetes/applications/argocd/<app>/manifests
  destination:
    server: https://kubernetes.default.svc
    namespace: <app>
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

:::caution
`path` must start with `kubernetes/`, the directory that exists in the repository.
:::

## 3. Write the HTTPRoute

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: <app>
  namespace: <app>
spec:
  parentRefs:
    - name: cilium-gateway
      namespace: cilium-gateway
      sectionName: https
  hostnames:
    - <app>.home.cervant.net
  rules:
    - matches:
        - path:
            type: PathPrefix
            value: /
      backendRefs:
        - name: <app>
          port: 80
```

The `http` listener of the gateway already redirects all `*.home.cervant.net` traffic to HTTPS.

## 4. Merge to main

ArgoCD syncs the new Application automatically. Check it with:

```bash
kubectl -n argocd get application <app>
kubectl -n <app> get httproute
```

The `homelab-docs` app (`kubernetes/applications/argocd/homelab-docs`) is a complete example.
