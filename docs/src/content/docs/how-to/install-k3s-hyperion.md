---
title: Install K3s on Hyperion
description: Install K3s on the Hyperion node with the flags Cilium needs, and open the API to the LAN.
sidebar:
  order: 4
---

Hyperion runs K3s without its bundled networking, because Cilium replaces Flannel, kube-proxy, network policies and Traefik. [Clusters: Hyperion and Cronos](/explanation/clusters/) explains why.

:::caution[Validated on K3s only]
The Hyperion stack has been tested only on K3s `v1.37.1+k3s1` running on Rocky Linux 10.2. It relies on K3s behavior, so it will not work unchanged on other distributions such as kubeadm, RKE2, k0s or MicroK8s. See [What the stack expects from K3s](/explanation/clusters/#what-the-stack-expects-from-k3s).
:::

## Install K3s

On `hyperion-01`:

```bash
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable traefik --disable-network-policy --disable-kube-proxy --flannel-backend=none --node-name=hyperion" sh -
```

Pods stay `Pending` and the node `NotReady` until Cilium is installed by [Apply the Hyperion stack](/how-to/apply-hyperion-stack/).

### If the install fails with `SSL certificate problem: self-signed certificate`

The script first resolves the `stable` channel against `update.k3s.io`. If a router or firewall breaks that one connection, you get this error even though GitHub and `get.k3s.io` work. Skip the lookup by pinning a version:

```bash
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION="v1.37.1+k3s1" INSTALL_K3S_EXEC="--disable traefik --disable-network-policy --disable-kube-proxy --flannel-backend=none --node-name=hyperion" sh -
```

Check the [K3s releases page](https://github.com/k3s-io/k3s/releases) for the latest version.

## Open the API server to trusted networks

The API server listens on `6443/tcp` on `192.168.10.201`. Allow it only from trusted internal networks:

```bash
sudo firewall-cmd --permanent --zone=public --add-rich-rule='rule family=ipv4 source address=192.168.10.0/24 port port=6443 protocol=tcp accept'
sudo firewall-cmd --permanent --zone=public --add-rich-rule='rule family=ipv4 source address=192.168.20.0/24 port port=6443 protocol=tcp accept'
sudo firewall-cmd --reload
sudo firewall-cmd --zone=public --list-rich-rules
```

Adjust the CIDRs to the networks that need cluster access. Do not open `6443/tcp` to all sources.

## Trust the pod network

Pods reach the API server through `10.43.0.1`, which Cilium translates to `192.168.10.201:6443` with the pod IP as source. firewalld drops that traffic unless the pod CIDR (Cilium's `cluster-pool` default, `10.0.0.0/8`) is trusted:

```bash
sudo firewall-cmd --permanent --zone=trusted --add-source=10.0.0.0/8
sudo firewall-cmd --reload
```

Without this, CoreDNS never becomes ready, `metrics-server` and `local-path-provisioner` crash with `dial tcp 10.43.0.1:443: i/o timeout`, and Helm releases such as Argo CD fail to install.

## Open HTTP and HTTPS for the Gateway

The shared Gateway gets the node IP (`192.168.10.201`) as its LoadBalancer address, through the K3s ServiceLB. Open `80/tcp` and `443/tcp` so clients on the LAN can reach the apps:

```bash
sudo firewall-cmd --permanent --zone=public --add-service=http --add-service=https
sudo firewall-cmd --reload
```

Without this, DNS resolves and the certificate is `Ready`, but browsers time out on every `*.home.cervant.net` hostname.

## Configure your kubeconfig

Copy `/etc/rancher/k3s/k3s.yaml` from the node and change the server to `https://192.168.10.201:6443` (not `127.0.0.1`). Then:

```bash
export KUBECONFIG=/path/to/hyperion-kubeconfig.yaml
```

Check connectivity from Windows with:

```powershell
Test-NetConnection 192.168.10.201 -Port 6443
```

## Start over

To remove K3s completely:

```bash
sudo /usr/local/bin/k3s-uninstall.sh
```
