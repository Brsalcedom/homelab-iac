# LXC Monitoring Stack

Incremental rollout for monitoring LXC:

1. Bootstrap host (Docker and runtime directories).
2. Install Komodo Core + Periphery.
3. Deploy Homepage and Dozzle stacks from Komodo (GitOps).
4. Validate service health.

## Files

- `homepage.yaml`: Homepage compose stack.
- `dozzle.yaml`: Dozzle compose stack.
- `komodo.yaml`: Komodo Core + Mongo + Periphery bootstrap stack.
- `komodo.env.example`: Variables template for Komodo stack.

## Step 2: Install Komodo

Use workflow:

- `.github/workflows/lxc-monitoring-bootstrap.yaml`

Required repository secrets:

- `BW_TOKEN`

## Step 3: Deploy Homepage and Dozzle from Komodo

The bootstrap already leaves Komodo Core with `github.com` configured as a Git provider.
If, when launching the workflow, you also pass `komodo_github_account` and `komodo_github_token_secret_id`, Komodo can clone this private repository directly. The token is still fetched from Bitwarden during bootstrap. If you leave those inputs empty, Komodo will only be able to use public repositories.

In Komodo Core UI:

1. Verify the `lxc-monitoring` server exists.
2. Create stack `homepage` in `Git Repo` mode:
   - Repo: `Brsalcedom/homelab-iac`
   - Branch: your target branch, usually `main`
   - Git provider: `github.com`
   - Git account: the value passed in `komodo_github_account`, otherwise empty for public repos
   - Compose file path: `docker/compose/lxc-monitoring/homepage.yaml`
3. Create stack `dozzle` in `Git Repo` mode:
   - Repo: `Brsalcedom/homelab-iac`
   - Branch: your target branch, usually `main`
   - Git provider: `github.com`
   - Git account: the value passed in `komodo_github_account`, otherwise empty for public repos
   - Compose file path: `docker/compose/lxc-monitoring/dozzle.yaml`
4. Enable auto deploy on git push for both stacks if you want redeploys on repo changes.

## Step 4: Validation

After deploy, verify:

- Homepage: `http://192.168.1.114:3000`
- Dozzle: `http://192.168.1.114:8088`
- Komodo Core: `http://192.168.1.114:9120`
- Periphery API reachable from Core: `https://192.168.1.114:8120`

Optional command checks on host:

```bash
docker ps
cd /opt/monitoring/komodo && docker compose -f komodo.yaml ps
```
