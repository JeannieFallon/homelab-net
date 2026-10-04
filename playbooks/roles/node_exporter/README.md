# node_exporter

Installs Debian's `prometheus-node-exporter` package on a host, starts it, and allows port 9100 only from the
monitoring server.

Applied to `all` in `site.yml`, after `common`, which sets ufw to deny incoming traffic by default.

## Variables

All in `defaults/main.yml`:

| Variable | Default | Purpose |
| --- | --- | --- |
| `node_exporter_port` | `9100` | Port opened in ufw. The package's own listen address is left at its default. |
| `node_exporter_allowed_sources` | `ansible_host` of every host in `monitoring` | Addresses allowed to reach the port |

Every host in `monitoring` needs `ansible_host` set to its IP address in the inventory.

## Deviations from the walkthrough

Compared with [`01_node-metrics.md`](../../../03_net-monit-stack/manual/01_node-metrics.md), sections 1 and 3:

- **Every host, not just the dev VM.** The walkthrough installed node exporter on one monitored host. The role runs on
  every host in the inventory, including the control node and the monitoring server.
- **The allowed source comes from the inventory.** The walkthrough typed the Prometheus VM's IP into
  `ufw allow from [PROMETHEUS_IP]`. The role reads it from the `monitoring` group, so moving the monitoring server is an
  inventory change.
- **SSH is no longer opened here.** The walkthrough's firewall section also ran `ufw allow OpenSSH` from anywhere. The
  `common` role now allows SSH, from `lan_cidrs` only.
- **No browser check of `:9100/metrics` from the LAN.** The port is closed to everything but the monitoring server, so
  the walkthrough's check from a desktop no longer works by design. The verification play at the end of `site.yml`
  checks that every host is `up` in Prometheus instead.
- **Debian 13, not 12** ([ADR 0004](../../../docs/adr/0004-debian-13-base.md)).

The role doesn't remove the rule for an old address when the monitoring server's IP changes. Delete it by hand with
`ufw status numbered` and `ufw delete <n>`.

## Verification status

Linted with `ansible-lint` (production profile). **Not yet run on hardware.**
