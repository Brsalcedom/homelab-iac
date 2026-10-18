---
title: Use Infisical secrets in an app
description: Set up the self-hosted Infisical once per cluster, then sync its secrets into an app's Kubernetes Secret with the Infisical operator.
sidebar:
  order: 7
---

Apps on Hyperion read secrets from the self-hosted Infisical at `https://infisical.home.cervant.net`. The Infisical operator copies them into a regular Kubernetes `Secret`. It authenticates with **Kubernetes Auth**, using the `infisical-auth` ServiceAccount in `infisical-operator-system`, so no credential is stored in Git or Bitwarden.

```text
Infisical project ──(operator, Kubernetes Auth)──▶ Secret in the app namespace ──(envFrom)──▶ pods
```

:::caution[No backups yet]
Infisical stores its data in the `infisical-postgresql` CloudNativePG cluster, on the node's `local-path` storage, without backups. If the cluster is rebuilt, every secret in Infisical is lost, even though `INFISICAL_ENCRYPTION_KEY` is safe in Bitwarden. Keep a copy of anything you can't regenerate.
:::

## Set up Infisical (once per cluster)

The `infisical-server` app deploys Infisical, but its organization, project and identity are created by hand.

1. **Create the admin account.** Open `https://infisical.home.cervant.net` and sign up right after the first deploy. The first account to sign up becomes the instance admin.
2. **Create a project** with a `prod` environment. Infisical derives the project **slug** from the name and adds a random suffix (the `hyperion` project has the slug `hyperion-8-jio`). Copy the slug from the project settings.
3. **Create a machine identity** under *Organization → Access Control → Identities* and add **Kubernetes Auth** to it:

   | Field | Value |
   |-------|-------|
   | Kubernetes Host | `https://kubernetes.default.svc.cluster.local` |
   | Token Reviewer JWT | Empty. Infisical reviews each token with the token itself, which is why `infisical-auth` is bound to `system:auth-delegator`. |
   | Allowed Service Account Names | `infisical-auth` |
   | Allowed Namespaces | `infisical-operator-system` |
   | Allowed Audience | Empty |
   | CA Certificate | Output of `kubectl -n default get cm kube-root-ca.crt -o jsonpath='{.data.ca\.crt}'` |

   The Kubernetes Host resolves to a private IP. Infisical only accepts it because the `infisical-server` app sets `ALLOW_INTERNAL_IP_CONNECTIONS=true`. Without it, saving fails with `Local IPs not allowed as URL`.
4. **Add the identity to the project** with a read-only role, and copy its **Identity ID**.

## Add a secret to an app

1. Create the secret in the Infisical project, for example `my_api_key` in `prod` at `/`.
2. Add an `InfisicalSecret` to the app's `manifests/`:

   ```yaml
   apiVersion: secrets.infisical.com/v1alpha1
   kind: InfisicalSecret
   metadata:
     name: <app>-secrets
     namespace: <app>
   spec:
     resyncInterval: 300
     authentication:
       kubernetesAuth:
         identityId: <identity-id>
         autoCreateServiceAccountToken: true
         serviceAccountRef:
           name: infisical-auth
           namespace: infisical-operator-system
         secretsScope:
           projectSlug: <project-slug>
           envSlug: prod
           secretsPath: "/"
     managedKubeSecretReferences:
       - secretName: <app>-secrets
         secretNamespace: <app>
         creationPolicy: Owner
         template:
           includeAllSecrets: false
           data:
             MY_API_KEY: "{{ .my_api_key.Value }}"
   ```

   The operator reaches Infisical at the `hostAPI` set in the `infisical-config` ConfigMap (`http://infisical.infisical.svc.cluster.local:8080/api`), so the `InfisicalSecret` doesn't set one.
3. Read the Secret from the workload, and let the operator restart it when the value changes:

   ```yaml
   apiVersion: apps/v1
   kind: Deployment
   metadata:
     name: <app>
     annotations:
       secrets.infisical.com/auto-reload: "true"
   spec:
     template:
       spec:
         containers:
           - name: <app>
             envFrom:
               - secretRef:
                   name: <app>-secrets
   ```

   Environment variables are only read when a container starts. Without `auto-reload`, pods keep the old value until they restart.

`netbird` (`kubernetes/applications/argocd/netbird/manifests`) is a complete example.

## How changes propagate

| Change | When it reaches the pods |
|--------|--------------------------|
| Value edited in Infisical | Within `resyncInterval` seconds the operator updates the Secret, then `auto-reload` rolls the Deployment |
| `InfisicalSecret` edited in Git | On the next ArgoCD sync, the operator reconciles right away |

## Check the result

```bash
kubectl -n <app> get infisicalsecret <app>-secrets \
  -o jsonpath='{range .status.conditions[*]}{.type}={.status} {.message}{"\n"}{end}'
kubectl -n <app> get secret <app>-secrets
```

`LoadedInfisicalToken` and `ReadyToSyncSecrets` should both be `True`.

## Troubleshooting

| Symptom | Cause |
|---------|-------|
| `Local IPs not allowed as URL` when saving Kubernetes Auth | `ALLOW_INTERNAL_IP_CONNECTIONS` is not set on `infisical-server` |
| `LoadedInfisicalToken=False` | Login failed: check the allowed ServiceAccount and namespace, the CA certificate, and that no audience is set |
| `Project with slug '…' not found` | `projectSlug` holds the project name, or the identity isn't a member of the project |
| Pods stuck in `CreateContainerConfigError`, `secret "…" not found` | The `InfisicalSecret` isn't syncing yet; check its conditions |
| Pods still use an old value | The Deployment lacks `secrets.infisical.com/auto-reload`, or `resyncInterval` hasn't elapsed |
