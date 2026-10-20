---
title: Add Pocket ID SSO to an app
description: Log in to an app on Hyperion with Pocket ID over OpenID Connect, with admin access from a group and the client secret in Infisical.
sidebar:
  order: 12
---

Every app with a login on `*.home.cervant.net` uses [Pocket ID](https://pocket.home.cervant.net) as its identity provider. zot and ArgoCD follow the same pattern:

- **A group `<app>_admins`** in Pocket ID. The app reads it from the `groups` claim and gives its members admin access. The claim carries the group's **name**, not its friendly name, so the app's config must use that exact string, with underscores.
- **An OIDC client per app**, with the app's callback URL and the group as allowed group. Its credentials live in Infisical, and an `InfisicalSecret` syncs them into the app's namespace.
- **A local break-glass account**, where the app supports one, for when Pocket ID is down.

## Pattern

1. In Pocket ID, create the `<app>_admins` group and add yourself to it.
2. Create an OIDC client named `<app>`, with the callback URL from the app's docs and `<app>_admins` as allowed group.
3. Add the client ID and secret to Infisical (`hyperion`, `prod`, `/`) as `<app>_oidc_client_id` and `<app>_oidc_client_secret`.
4. Render them into a Secret with an `InfisicalSecret` (see [Use Infisical secrets in an app](/how-to/use-infisical-secrets/)), in the format the app reads.
5. Configure the app with issuer `https://pocket.home.cervant.net`, scopes `openid profile email groups`, and the group mapped to its admin role.

zot is described in [Use the zot registry](/how-to/use-zot-registry/#log-in-with-pocket-id). ArgoCD is below.

## ArgoCD

ArgoCD talks OIDC to Pocket ID directly, so its bundled Dex is disabled. The configuration is split in two because ArgoCD is installed by OpenTofu, before the Infisical operator exists:

| Piece | Where | Applied by |
|-------|-------|------------|
| `oidc.config`, RBAC, `dex.enabled: false` | Helm values in `terraform/proxmox/infraestructure/hyperion/argocd.tf` | `Tofu :: k8s hyperion` |
| `argocd-oidc` Secret | `InfisicalSecret` in `kubernetes/applications/argocd/argocd-sso` | ArgoCD |

`oidc.config` refers to the Secret as `$argocd-oidc:<key>`. ArgoCD only resolves those references from Secrets labeled `app.kubernetes.io/part-of: argocd`, so the `InfisicalSecret` sets that label with `template.metadata.labels`.

### Two clients

`argocd login --sso` runs the authorization code flow from your machine and can't hold a client secret, so the CLI needs a public client:

| Client | Type | Callback URL | Used by |
|--------|------|--------------|---------|
| `argocd` | Confidential | `https://argocd.home.cervant.net/auth/callback` | The UI (`clientID`, `clientSecret`) |
| `argocd-cli` | Public (PKCE) | `http://localhost:8085/auth/callback` | `argocd login --sso` (`cliClientID`) |

### Set up (once)

1. In Pocket ID, create the `argocd_admins` group and add yourself to it.
2. Create the `argocd` and `argocd-cli` clients from the table, both with `argocd_admins` as allowed group. Mark `argocd-cli` as a public client.
3. Add these secrets to Infisical (`hyperion`, `prod`, `/`):

   | Secret | Value |
   |--------|-------|
   | `argocd_oidc_client_id` | Client ID of `argocd` |
   | `argocd_oidc_client_secret` | Client secret of `argocd` |
   | `argocd_cli_oidc_client_id` | Client ID of `argocd-cli` |

4. Merge. ArgoCD syncs `argocd-sso`, and `Tofu :: k8s hyperion` applies the Helm values. ArgoCD picks up the Secret without a restart.

### Access

| Who | Role | How |
|-----|------|-----|
| Members of `argocd_admins` | `role:admin` | **Log in via Pocket ID** in the UI, or `argocd login argocd.home.cervant.net --sso --grpc-web` |
| `admin` | `role:admin` | Break-glass if Pocket ID is down. Password in your password manager |
| Anyone else in Pocket ID | None | `policy.default` is empty |

### Check it

```bash
kubectl -n argocd get secret argocd-oidc -o jsonpath='{.metadata.labels}'
kubectl -n argocd get deploy argocd-dex-server   # NotFound once Dex is disabled
```

| Symptom | Cause |
|---------|-------|
| No Pocket ID button, or `invalid client` | `argocd-oidc` is missing, unlabeled, or has the wrong keys. `argocd-server` logs `secret key does not exist in secret`. |
| Pocket ID says `Invalid callback URL` | The client ID belongs to the other client (`argocd` and `argocd-cli` swapped in Infisical), or the callback in Pocket ID doesn't match exactly |
| Login works but no apps are visible | Your groups don't include `argocd_admins`. **User Info** in the UI lists the groups ArgoCD read from the token. Log out and back in after changing a membership. |
