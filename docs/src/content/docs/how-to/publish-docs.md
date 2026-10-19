---
title: Write and publish these docs
description: Edit the wiki locally, and set up the two publication targets (Cloudflare and Hyperion).
sidebar:
  order: 9
---

The wiki lives in `docs/` and is built with [Starlight](https://starlight.astro.build). [Docs delivery](/explanation/docs-delivery/) explains the design.

## Edit locally

```bash
cd docs
npm ci
npm run dev
```

Open `http://localhost:4321`. Pages are Markdown files under `docs/src/content/docs/`, grouped by Diátaxis type:

| Folder         | Put here                                           |
|----------------|----------------------------------------------------|
| `tutorials/`   | A guided lesson with a known end state             |
| `how-to/`      | Steps to reach one goal, for someone who knows the basics |
| `reference/`   | Facts to look up: tables, variables, inputs        |
| `explanation/` | Background, design decisions, trade-offs           |

The sidebar is generated from the folders. Use `sidebar.order` in the frontmatter to sort pages.

Check the production build before pushing:

```bash
npm run build
npm run preview
```

## Publish

Merge to `main`. The [`Docs`](/reference/ci-workflows/#docs) workflow builds once and publishes to:

- `https://docs.cervant.net` (Cloudflare Workers static assets)
- `https://docs.home.cervant.net` (nginx image in zot, run on Hyperion and updated by ArgoCD Image Updater)

The image is also pushed to GHCR as an off-site copy. On each release, the image is tagged with the release version as well (see [Docs delivery](/explanation/docs-delivery/#release-versions)).

## One-time setup

### Cloudflare

1. Create an API token with the **Edit Cloudflare Workers** template, scoped to the account and to the `cervant.net` zone.
2. Store the token and the account ID in Bitwarden Secrets Manager, and put their IDs in the **Get secrets from Bitwarden** step of the `cloudflare` job in `.github/workflows/docs.yaml` (they start as `00000000-...` placeholders).

On the first deploy, `wrangler` creates the `homelab-docs` Worker and the `docs.cervant.net` custom domain (DNS record and certificate) from `docs/wrangler.jsonc`.

To deploy by hand:

```bash
cd docs
npm run build
npx wrangler login
npm run deploy:cloudflare
```

### Hyperion

1. Set up the zot users and credentials described in [Use the zot registry](/how-to/use-zot-registry/):
   - `homelab-ci-push` and `homelab-cd-pull` in `zot_htpasswd`.
   - The `homelab-ci-push` password in Bitwarden, with its ID in the **Get secrets from Bitwarden** step of the `image` job in `docs.yaml` and of the `docs-image` job in `release-please.yaml`.
   - `zot_pull_auth` in Infisical, used by `homelab-docs/manifests/pull-secrets.yaml`.
2. Make sure `docs` is listed under `cnames.hyperion-01` in `pihole/records.yaml`, so `docs.home.cervant.net` resolves to the Cilium Gateway (see [Manage internal DNS records](/how-to/manage-internal-dns/)).
3. Apply the Hyperion stack once after `argocd.tf` changes, so the root app ignores the image overrides (see [Docs delivery](/explanation/docs-delivery/)).

Image Updater checks zot every two minutes, so `docs.home.cervant.net` updates a few minutes after `docs.cervant.net`. To see what it did:

```bash
kubectl -n argocd logs deploy/argocd-image-updater-controller | grep homelab-docs
kubectl -n argocd get application homelab-docs -o jsonpath='{.spec.source.kustomize.images}'
```

No certificate work is needed: the gateway's wildcard certificate for `*.home.cervant.net` already covers the hostname.
