# Docker Compose by LXC

This directory groups compose stacks by target LXC role.

## Layout

- `lxc-auth/`: authentication services (e.g. Authentik)
- `lxc-monitoring/`: observability dashboards and logging
- root-level files: legacy stacks pending migration

## GitOps direction

- Bootstrap tasks should only prepare the host (Docker, base dependencies, agent install).
- Compose sync and ongoing deployments should be handled by Komodo from Git.
