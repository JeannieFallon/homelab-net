# prometheus

Installs Debian's `prometheus` package on the monitoring server, makes it listen on `127.0.0.1:9090` only, and writes
a scrape config with one `node` target per inventory host plus a self-scrape job.

Applied to `monitoring` in `site.yml`.

## Variables

All in `defaults/main.yml`:

| Variable | Default | Purpose |
| --- | --- | --- |
| `prometheus_listen_address` | `127.0.0.1:9090` | Address Prometheus listens on |
| `prometheus_args` | `--web.listen-address=...` | Flags written to `ARGS` in `/etc/default/prometheus` |
| `prometheus_scrape_interval` | `15s` | Global scrape and evaluation interval |
| `prometheus_node_exporter_port` | `9100` | Port scraped on every inventory host |

Every host in the inventory needs `ansible_host` set to its IP address. Adding a host to the inventory and rerunning
`site.yml` makes it a target with no other edits. Each target's `instance` label is its inventory name, not `IP:port`.

## Reaching the web UI

Prometheus isn't reachable from the LAN. Tunnel to it over SSH and open `http://localhost:9090`:

```bash
ssh -L 9090:localhost:9090 <monitoring-server>
```

## Deviations from the walkthrough

Compared with [`01_node-metrics.md`](../../../03_net-monit-stack/manual/01_node-metrics.md), sections 2 and 3:

- **Debian package instead of the upstream tarball.** The walkthrough downloaded Prometheus 3.4.1, moved the binaries
  into `/usr/local/bin`, and wrote its own system user and systemd unit. The role installs the Debian 13 package
  (2.53.3, a major version behind upstream), which brings its own user, unit, and security updates
  ([ADR 0002](../../../docs/adr/0002-prometheus-from-debian-package.md)).
- **Localhost only, on the monitoring server.** The walkthrough ran Prometheus on its own VM, listening on all
  interfaces, and opened 9090 to a desktop. Prometheus and Grafana now share one VM
  ([ADR 0001](../../../docs/adr/0001-colocate-prometheus-and-grafana.md)), so Prometheus listens on `127.0.0.1` and
  there is no firewall rule for 9090. The web UI is reached through an SSH tunnel.
- **Targets come from the inventory.** The walkthrough's `node_exporter_targets` job listed one hand-typed target. The
  `node` job is generated from `groups['all']`, and the config is checked with `promtool check config` before it's put
  in place.
- **Reload instead of restart.** A scrape config change reloads Prometheus. Only a change to the flags restarts it.
- **Debian 13, not 12** ([ADR 0004](../../../docs/adr/0004-debian-13-base.md)).

## Verification status

Linted with `ansible-lint` (production profile). The template was rendered against the example inventory and passed
`promtool check config` from the upstream 2.53.3 release, the version Debian 13 packages. The upstream 2.53.3 binary
also confirmed that a static `instance` label replaces the default `IP:port`. **Not yet run on hardware.** To confirm
on the monitoring server:

- The Debian unit reads `ARGS` from `/etc/default/prometheus`, the file ships with an `ARGS=` line, and the unit
  supports reload (from memory).
- `promtool` is in the `prometheus` package (from memory).
- **The packaged web UI works.** Debian has had trouble packaging the React UI (from memory). If the UI is missing or broken, that's
  the trigger to revisit [ADR 0002](../../../docs/adr/0002-prometheus-from-debian-package.md). Result: _not yet
  checked._
