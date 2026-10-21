---
title: Manage internal DNS records
description: Add, change or remove *.home.cervant.net records on Pi-hole through pihole/records.yaml.
sidebar:
  order: 11
---

The local DNS records of Pi-hole (`pihole-01`, `192.168.10.150`) are defined in `pihole/records.yaml`. The `Pi-hole :: DNS records` workflow shows the diff on pull requests and applies it on `main`.

:::caution
An apply replaces `dns.hosts`, `dns.cnameRecords` and `misc.dnsmasq_lines` as a whole. A record or dnsmasq line created by hand in the Pi-hole UI is removed on the next apply: add it to `records.yaml` or the task instead.
:::

## Pi-hole answers for the whole domain

Besides the records, the apply sets `misc.dnsmasq_lines` to `local=/home.cervant.net/`. dnsmasq answers every name under that domain from its local records only: a name that isn't in `records.yaml` gets `NXDOMAIN`, and the query never reaches Cloudflare.

Without it, Pi-hole forwards unknown names to Cloudflare. `cervant.net` is signed with DNSSEC, and for a name that doesn't exist Cloudflare answers `NOERROR` with no records instead of `NXDOMAIN`. That breaks containers built on musl (Alpine): pods have `home.cervant.net` in their search list and `ndots:5`, so `grafana.com` is tried first as `grafana.com.home.cervant.net`. musl only moves on to the next search domain after `NXDOMAIN`; on the empty answer it gives up, and the lookup fails with `Could not resolve host`.

Records under `home.cervant.net` in Cloudflare are no longer visible from the LAN. cert-manager isn't affected: it checks its DNS-01 records against `1.1.1.1`.

```bash
nslookup does-not-exist.home.cervant.net 192.168.10.150   # NXDOMAIN
```

## The file

```yaml
domain: home.cervant.net

hosts:              # A records: name -> IPv4
  hyperion-01: 192.168.10.201

cnames:             # CNAME records, grouped by target
  hyperion-01:
    - argocd
    - docs
```

Names are relative to `domain`. Each CNAME target must be defined in the same file, as a host or as another alias: dnsmasq only follows a CNAME whose target it knows locally, so every chain has to end at a host.

## Add a record

- **App on Hyperion:** add its name under `cnames.hyperion-01`, the node that answers for the Cilium Gateway.
- **Service behind Nginx Proxy Manager on Swarm:** add its name under `cnames.npm`.
- **New machine:** add it under `hosts` with its IP.

Open a pull request: the **Diff** job writes the changes to the job summary. Merge to apply.

## Run it by hand

The task needs the SSH key that is authorized on the LXC containers. From the repository root, on Linux:

```bash
export LXC_HOST=192.168.10.150 SSH_KEY_PATH=~/.ssh/id_ed25519
task --taskfile .github/tasks/pihole-dns-sync.yml render   # validate only, no SSH
task --taskfile .github/tasks/pihole-dns-sync.yml diff
task --taskfile .github/tasks/pihole-dns-sync.yml apply
```

The task downloads a pinned `yq` (Linux amd64) to `/tmp/pihole-dns/bin`, since the CI image doesn't ship it.

To see what Pi-hole has right now:

```bash
ssh root@192.168.10.150 "pihole-FTL --config dns.hosts; pihole-FTL --config dns.cnameRecords; pihole-FTL --config misc.dnsmasq_lines"
```

## How the apply works

1. **Validate:** names are valid DNS labels and unique, IPs are IPv4, and every CNAME chain ends at a host without loops.
2. **Render:** builds the three arrays: `"<ip> <name>.<domain>"`, `"<alias>.<domain>,<target>.<domain>"` and `"local=/<domain>/"`.
3. **Diff:** reads the current arrays with `pihole-FTL --config` over SSH and compares them as sorted sets, so the order Pi-hole stores them in doesn't show up as a change.
4. **Apply:** if there is a diff, writes the arrays with `pihole-FTL --config <key> '<json>'` and reads them back to check they match.
