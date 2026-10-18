---
title: Set up the GitHub self-hosted runner
description: Turn the github-runner-01 LXC container into a self-hosted GitHub Actions runner with Docker.
sidebar:
  order: 8
---

The `github-runner-01` container (`192.168.10.111`) runs the workflows that need access to the LAN: OpenTofu plans and applies against Proxmox and Hyperion, the LXC bootstrap jobs, and the jobs that push the docs image to [zot](/how-to/use-zot-registry/). The OpenTofu and bootstrap jobs run inside the `brsalcedom/homelab-ci` image, and the image jobs use Docker Buildx directly, so the runner needs Docker with the Buildx plugin.

This guide is for **Debian 13**. On another OS, follow the [official Docker install docs](https://docs.docker.com/engine/install/) for step 2.

## Prerequisites

- The `github-runner-01` container is deployed (see [Deploy LXC containers](/how-to/deploy-lxc-containers/)).
- The SSH private key set when the container was created.
- Admin access to the repository on GitHub, to get a registration token.

Connect as root:

```bash
ssh -i ~/.ssh/id_ed25519 root@192.168.10.111
```

Steps 1 to 3 run as `root` without `sudo`.

## 1. Install base packages

```bash
apt update
apt install -y curl git sudo ca-certificates
```

## 2. Install Docker

```bash
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

docker run hello-world
```

## 3. Create the runner user

The runner must not run as root.

```bash
useradd -m -s /bin/bash github
usermod -aG docker github
usermod -aG sudo github
```

## 4. Download and register the runner

Switch to the new user:

```bash
su - github
mkdir -p ~/actions-runner && cd ~/actions-runner
```

Download the runner. Replace `2.331.0` with the latest version from the [runner releases page](https://github.com/actions/runner/releases), and check the hash published there:

```bash
curl -o actions-runner-linux-x64-2.331.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.331.0/actions-runner-linux-x64-2.331.0.tar.gz
echo "<hash>  actions-runner-linux-x64-2.331.0.tar.gz" | sha256sum -c
tar xzf ./actions-runner-linux-x64-2.331.0.tar.gz
```

Get a registration token in GitHub under **Settings → Actions → Runners → New self-hosted runner**, then:

```bash
./config.sh --url https://github.com/Brsalcedom/homelab-iac --token <TOKEN>
```

Accept the defaults, except the runner name: use `github-runner-01`.

## 5. Install the runner as a systemd service

Go back to root (`exit`) and run:

```bash
cd /home/github/actions-runner
sudo ./svc.sh install github
sudo ./svc.sh start
sudo ./svc.sh status
```

The service name is `actions.runner.<owner>-<repo>.<runner>.service`, here `actions.runner.Brsalcedom-homelab-iac.github-runner-01.service`. Enable it at boot:

```bash
sudo systemctl enable actions.runner.Brsalcedom-homelab-iac.github-runner-01.service
```

## 6. Verify

1. In GitHub, **Settings → Actions → Runners** shows `github-runner-01` as **Idle**.
2. Run any `workflow_dispatch` workflow (for example `Tofu :: Proxmox VM`) and check that the runner picks it up.

## Operate the runner

```bash
cd /home/github/actions-runner
sudo ./svc.sh stop
sudo ./svc.sh start
sudo ./svc.sh uninstall

# Service logs
sudo journalctl -u actions.runner.Brsalcedom-homelab-iac.github-runner-01.service -f

# Runner logs
sudo -u github tail -f /home/github/actions-runner/_diag/*.log
```

### Update the runner

```bash
cd /home/github/actions-runner
sudo ./svc.sh stop
sudo -u github curl -o actions-runner-linux-x64-<VERSION>.tar.gz -L https://github.com/actions/runner/releases/download/v<VERSION>/actions-runner-linux-x64-<VERSION>.tar.gz
sudo -u github tar xzf ./actions-runner-linux-x64-<VERSION>.tar.gz
sudo ./svc.sh start
```

## Troubleshooting

| Symptom | Check |
|---------|-------|
| Runner doesn't appear in GitHub | `systemctl status` and `journalctl -n 50` for the service |
| Docker permission denied in jobs | `groups github` must include `docker`; if not, `usermod -aG docker github` and restart the service |
| Runner shows **Offline** | Connectivity to `github.com`, then restart the service |

## Security notes

- The `github` user can reach the Docker socket and its work directory `~/actions-runner/_work`.
- Secrets come from GitHub Secrets and from Bitwarden Secrets Manager (`bitwarden/sm-action`). Never store secrets on the container.
- Watch CPU, RAM and disk usage of the container; container jobs and images add up.
