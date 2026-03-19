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

In Komodo Core UI:

1. Add server using Periphery endpoint:
   - URL: `https://192.168.1.114:8120`
   - Passkey: value of `PERIPHERY_PASSKEYS`
2. Create stack `homepage` with Git file path:
   - `docker/compose/lxc-monitoring/homepage.yaml`
3. Create stack `dozzle` with Git file path:
   - `docker/compose/lxc-monitoring/dozzle.yaml`
4. Enable auto deploy on git push for both stacks.

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
