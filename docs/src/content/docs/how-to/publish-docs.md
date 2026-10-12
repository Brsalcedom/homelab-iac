---
title: Write and publish these docs
description: Edit the wiki locally, and set up the two publication targets (Cloudflare and Hyperion).
sidebar:
  order: 8
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
- `https://docs.home.cervant.net` (nginx image on Hyperion, updated by ArgoCD Image Updater)

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

1. After the first image push, make the `ghcr.io/brsalcedom/homelab-docs` package public (**GitHub → Packages → homelab-docs → Package settings**). Otherwise the cluster needs an `imagePullSecret`.
2. Make sure `docs.home.cervant.net` resolves to the Cilium Gateway address in the internal DNS (Pi-hole, `192.168.10.150`), unless a wildcard `*.home.cervant.net` record already covers it.
3. Apply the Hyperion stack once after `argocd.tf` changes, so the root app ignores the image overrides (see [Docs delivery](/explanation/docs-delivery/)).

Image Updater checks GHCR every two minutes, so `docs.home.cervant.net` updates a few minutes after `docs.cervant.net`. To see what it did:

```bash
kubectl -n argocd logs deploy/argocd-image-updater-controller | grep homelab-docs
kubectl -n argocd get application homelab-docs -o jsonpath='{.spec.source.kustomize.images}'
```

No certificate work is needed: the gateway's wildcard certificate for `*.home.cervant.net` already covers the hostname.
