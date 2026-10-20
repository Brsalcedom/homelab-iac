---
title: Use the zot registry
description: Push images to zot from CI, pull them on Hyperion with read-only credentials, and manage registry users.
sidebar:
  order: 10
---

[zot](https://zotregistry.dev) is the internal OCI registry at `https://zot.home.cervant.net`. The `zot` app deploys it from the upstream Helm chart, plus `zot/manifests/` with the `HTTPRoute` and the `InfisicalSecret` that holds its users. It is only reachable from the LAN, and every request needs a user: there is no anonymous access, so the UI asks for a login too.

:::caution[No backups]
Images are stored on a 20Gi `local-path` volume on the node, without backups. Anything pushed only to zot is lost if the node is rebuilt. The docs image is also pushed to GHCR for that reason.
:::

## Users

Users come from an htpasswd file stored in Infisical as `zot_htpasswd` (project `hyperion`, `prod`, `/`). The permissions are in `accessControl`, in the `config.json` of `zot/application.yaml`.

| User | Can | Used by | Password stored in |
|------|-----|---------|--------------------|
| Members of `zot_admins` in Pocket ID | Read, push, delete | You, from the UI, and the CLI with an API key | Pocket ID (passkey) |
| `admin` | Read, push, delete | Break-glass access if Pocket ID is down | Your password manager |
| `homelab-ci-push` | Read, push | CI jobs on the self-hosted runner | Bitwarden Secrets Manager |
| `homelab-cd-pull` | Read | The kubelet and ArgoCD Image Updater | Infisical, as `zot_pull_auth` |

Push and pull use separate users because ArgoCD Image Updater deploys every new `:latest` digest it finds. A push credential inside the cluster would let anyone who can read those Secrets ship an image to Hyperion. The pull credential only lets them download images.

### Permissions

htpasswd only decides who can log in. What each user can do is set in `accessControl`:

```json
"accessControl": {
  "repositories": {
    "**": {
      "defaultPolicy": ["read"],
      "policies": [
        {
          "users": ["homelab-ci-push"],
          "actions": ["read", "create", "update"]
        }
      ]
    }
  },
  "adminPolicy": {
    "users": ["admin"],
    "actions": ["read", "create", "update", "delete"]
  }
}
```

| Field | Applies to |
|-------|------------|
| `repositories."**"` | Every repository. Use a pattern such as `homelab-docs` or `apps/**` to scope rules to some repositories. |
| `defaultPolicy` | Every authenticated user, including those not named anywhere (`homelab-cd-pull`) |
| `policies` | The users listed, on top of `defaultPolicy` |
| `adminPolicy` | The users listed, on every repository |

Permissions add up: a user gets `defaultPolicy` plus every rule that names them. Keep `defaultPolicy` at `read`, because anything added there applies to every user.

## Log in with Pocket ID

People log in to the UI with [Pocket ID](https://pocket.home.cervant.net) through OpenID Connect. Machine users (`homelab-ci-push`, `homelab-cd-pull`) stay in htpasswd.

- The username is the `preferred_username` claim, and the groups come from the `groups` claim. `adminPolicy` gives every action to members of the `zot_admins` group.
- `docker login` can't use OpenID Connect. Log in to the UI, create an API key from the user menu, and use it as the password:

  ```bash
  docker login -u <pocket-id-username> zot.home.cervant.net
  ```

### Set up (once)

1. In Pocket ID, create the `zot_admins` group and add yourself to it.
2. Create an OIDC client named `zot`, with callback URL `https://zot.home.cervant.net/zot/auth/callback/oidc` and `zot_admins` as allowed group.
3. Add these secrets to Infisical (`hyperion`, `prod`, `/`). `manifests/secrets.yaml` renders them into `zot-secrets`:

   | Secret | Value |
   |--------|-------|
   | `zot_oidc_client_id` | Client ID from Pocket ID |
   | `zot_oidc_client_secret` | Client secret from Pocket ID |
   | `zot_session_hash_key` | `openssl rand -hex 32` (64 characters) |
   | `zot_session_encrypt_key` | `openssl rand -hex 16` (32 characters) |

   The session keys sign and encrypt the UI session cookie. Without fixed keys, zot generates new ones on every start and logs everyone out.

All four must exist before the change is synced. A missing one renders as `<no value>` and breaks the JSON file that zot reads at startup.

## Add or change a user

1. Generate the line for the user:

   ```bash
   htpasswd -nbB <user> '<password>'
   ```

2. Add it to `zot_htpasswd` in Infisical, one line per user.
3. Any authenticated user can read. For more, add the user to a rule in [`accessControl`](#permissions) and merge.

The operator copies the new file into the `zot-secrets` Secret within `resyncInterval` (5 minutes), and `secrets.infisical.com/auto-reload` restarts `zot-0` with it.

## Push from CI

GitHub-hosted runners can't reach zot, so the job runs on the [self-hosted runner](/how-to/setup-github-runner/). Get the `homelab-ci-push` password (plaintext) from Bitwarden and log in before building:

```yaml
runs-on: self-hosted
steps:
  - name: 🔐 Get secrets from Bitwarden
    uses: bitwarden/sm-action@v3.0.1
    id: secrets-bw
    with:
      access_token: ${{ secrets.BW_TOKEN }}
      base_url: https://vault.bitwarden.com
      secrets: |
        ca9951e3-7c49-4c0d-a57c-b4e7011bdae8 > ZOT_PUSH_PASSWORD

  - name: 🔐 Login to zot
    uses: docker/login-action@v4
    with:
      registry: zot.home.cervant.net
      username: homelab-ci-push
      password: ${{ steps.secrets-bw.outputs.ZOT_PUSH_PASSWORD }}
```

The `image` job in `.github/workflows/docs.yaml` is a complete example.

## Pull from an app

The pull credential is stored once in Infisical as `zot_pull_auth`: the base64 of `homelab-cd-pull:<password>`, with the plaintext password.

```bash
printf 'homelab-cd-pull:<password>' | base64 -w0
```

1. Add an `InfisicalSecret` that renders it as a `dockerconfigjson` Secret in the app namespace:

   ```yaml
   apiVersion: secrets.infisical.com/v1alpha1
   kind: InfisicalSecret
   metadata:
     name: zot-pull
     namespace: <app>
   spec:
     resyncInterval: 300
     authentication:
       kubernetesAuth:
         identityId: c27d3730-f918-463d-8470-07eea18f40bd
         autoCreateServiceAccountToken: true
         serviceAccountRef:
           name: infisical-auth
           namespace: infisical-operator-system
         secretsScope:
           projectSlug: hyperion-8-jio
           envSlug: prod
           secretsPath: "/"
     managedKubeSecretReferences:
       - secretName: zot-pull
         secretNamespace: <app>
         secretType: kubernetes.io/dockerconfigjson
         creationPolicy: Owner
         template:
           includeAllSecrets: false
           data:
             .dockerconfigjson: '{"auths":{"zot.home.cervant.net":{"auth":"{{ .zot_pull_auth.Value }}"}}}'
   ```

2. Reference it from the Deployment:

   ```yaml
   spec:
     template:
       spec:
         imagePullSecrets:
           - name: zot-pull
         containers:
           - name: <app>
             image: zot.home.cervant.net/<app>:latest
   ```

3. If ArgoCD Image Updater follows the image, add a second copy of the `InfisicalSecret` in the `argocd` namespace and point the `ImageUpdater` to it with `pullSecret: pullsecret:argocd/<secret>`. Image Updater can only read Secrets in `argocd`.

`homelab-docs/manifests/pull-secrets.yaml` has both copies.

## Check the registry

```bash
curl -u homelab-cd-pull https://zot.home.cervant.net/v2/_catalog
curl -u homelab-cd-pull https://zot.home.cervant.net/v2/homelab-docs/tags/list
kubectl -n zot logs sts/zot
```

## Troubleshooting

| Symptom | Cause |
|---------|-------|
| `ImagePullBackOff` with `401 Unauthorized` | The pull Secret is missing from the namespace, or `zot_pull_auth` holds the htpasswd hash instead of the plaintext password |
| Push fails with `403 Forbidden` | The user has no `create` or `update` in `accessControl` |
| Push fails with `no such host` | The job runs on a GitHub-hosted runner instead of `self-hosted` |
| A new user can't log in | The operator hasn't resynced yet; check `kubectl -n zot get infisicalsecret zot-secrets` |
| Pocket ID login returns to zot without access | The user isn't in `zot_admins`, or the Pocket ID client lacks the `groups` scope |
| `redirect_uri` error on Pocket ID | The client's callback URL isn't exactly `https://zot.home.cervant.net/zot/auth/callback/oidc` |
| `zot-0` crash-loops after a change to `secrets.yaml` | One of the Infisical secrets is missing; check `kubectl -n zot logs sts/zot` |
| Large layer pushes cut after about 15 seconds | The `HTTPRoute` lost `timeouts.request: 0s`; Envoy's default route timeout is 15s |
