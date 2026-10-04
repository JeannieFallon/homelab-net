# grafana

Installs Grafana from Grafana's apt repo at an exact version and holds it there. Provisions the local Prometheus
datasource and the Node Exporter Full dashboard as code, sets the admin password from the vault, and allows port 3000
from `lan_cidrs` only.

Applied to `monitoring` in `site.yml`, after `prometheus`.

Grafana is served over plain HTTP. TLS behind a reverse proxy is deferred (see `ROADMAP.md`).

## Variables

Set in the vault (`group_vars/monitoring/vault.yml`, gitignored; see `vault.yml.example`):

| Variable | Purpose |
| --- | --- |
| `vault_grafana_admin_password` | Password for Grafana's built-in `admin` user. `group_vars/monitoring/main.yml` maps it to `grafana_admin_password`. |

Set in the inventory: `lan_cidrs`, the subnets allowed to reach port 3000 (shared with `common`).

Role defaults (`defaults/main.yml`):

| Variable | Default | Purpose |
| --- | --- | --- |
| `grafana_version` | `13.2.3` | Exact package version, held with dpkg |
| `grafana_apt_key_url`, `grafana_apt_key_checksum` | `gpg.key`, pinned SHA-256 | Repo signing key |
| `grafana_http_port` | `3000` | Port Grafana listens on and ufw opens |
| `grafana_datasource_uid` | `prometheus` | Fixed uid of the provisioned datasource |
| `grafana_datasource_url` | `http://127.0.0.1:9090` | Prometheus on the same VM |
| `grafana_dashboard_revision`, `grafana_dashboard_checksum` | `45`, pinned SHA-256 | Revision of dashboard 1860 |
| `grafana_dashboard_uid` | `rYdddlPWk` | The dashboard's uid, from its JSON. The verification play looks it up. |

## Changing a pin

- **Grafana version.** Set `grafana_version` to a version from `https://apt.grafana.com` and rerun `site.yml`. The role
  installs it through the hold. Read Grafana's upgrade notes first.
- **Dashboard revision.** Download the new revision from
  `https://grafana.com/api/dashboards/1860/revisions/<n>/download`, check its `uid` and how it selects a datasource,
  and update the revision, checksum, and uid together.
- **Signing key.** If the key download fails its checksum, Grafana has rotated the key. The current key expires on
  2027-08-22. Check the new key's fingerprint against Grafana's install docs before updating the checksum.

## Admin password

Grafana reads `admin_password` from `grafana.ini` only when it first creates its database. To keep the vault as the
source of truth after that, the role logs in to the API with the vault password after every run. If the login
succeeds, nothing changes. If it fails with 401, the role resets the password with `grafana cli admin
reset-admin-password`, which is the only case that reports a change. Changing the vault password therefore takes effect
on the next run, and the run after that is clean again.

## Deviations from the walkthrough

Compared with [`01_node-metrics.md`](../../../03_net-monit-stack/manual/01_node-metrics.md), sections 4 and 5:

- **One VM, no kiosk.** The walkthrough ran Grafana on its own VM with a desktop environment, `unclutter`, and a
  fullscreen browser on a TV over HDMI. Grafana now runs on the monitoring server next to Prometheus
  ([ADR 0001](../../../docs/adr/0001-colocate-prometheus-and-grafana.md)) as a LAN-only web app. There's no desktop
  environment, LXQt, or HDMI setup to maintain.
- **Pinned and held.** The walkthrough installed whatever `apt install grafana` gave. The role installs an exact version
  and holds it, so a routine `apt upgrade` can't change it.
- **Signing key in a `.asc` keyring, pinned by checksum.** The walkthrough piped `gpg.key` through `gpg --dearmor`
  into `/etc/apt/keyrings/grafana.gpg` and wrote a one-line `sources.list.d` entry. apt reads armored keys directly, so
  the role saves the key as `/etc/apt/keyrings/grafana.asc`, checks it against a pinned checksum, and writes a deb822
  `grafana.sources` file. Grafana's install docs now point at `gpg-full.key`, which also contains a 2017 key and a key
  that expired in 2025. The repo is signed by the 2023 key alone, which is the only key in `gpg.key`, so the role
  trusts only that one.
- **Provisioning instead of UI clicks.** The walkthrough logged in as `admin`/`admin`, added the datasource by hand,
  and imported dashboard 1860 by ID. The role sets the admin password from the vault before Grafana's first start,
  provisions the datasource with a fixed uid, and provisions the dashboard read-only (`allowUiUpdates: false`) from a
  pinned revision checked against a checksum.
- **Datasource on localhost.** The walkthrough pointed Grafana at `http://[PROMETHEUS_IP]:9090` and opened 9090 between
  VMs. Prometheus now listens on `127.0.0.1` on the same VM.
- **Anonymous access and sign-up are off** explicitly, and update checks and usage reporting are turned off because the
  version is pinned.

### Deviation from spec #10

The spec said to replace the dashboard's `${DS_PROMETHEUS}` placeholder with the datasource uid. Revision 45 has no
such placeholder and no `__inputs` section. It selects its datasource through a dashboard variable, `ds_prometheus`, of
type `datasource`, and its panels refer to `${ds_prometheus}`. The dashboard is therefore provisioned unmodified, and
the variable should pick up the provisioned datasource because it's the only Prometheus datasource and is marked
default. This was checked against the downloaded JSON for revision 45 on 2026-10-04.

## Verification status

Linted with `ansible-lint` (production profile). The version, signing key fingerprint and expiry, and the dashboard's
checksum, uid, and datasource variable were checked against the live repo and grafana.com on 2026-10-04. The service
name (`grafana-server`) and the `grafana cli admin reset-admin-password` syntax were checked against Grafana's docs.
**Not yet run on hardware.** To confirm on the monitoring server:

- The package doesn't start Grafana on install, so `admin_password` is in place before the database is created (from
  memory). The acceptance check is that `admin`/`admin` fails after the first deploy.
- `ds_prometheus` selects the provisioned datasource with no UI clicks (from memory).
- Running `grafana cli` as root leaves no root-owned files that block Grafana from writing its SQLite database. SQLite
  doesn't use WAL by default in Grafana, so the journal is removed after the write (from memory). The password is
  passed as an argument and briefly visible in the process list, because the documented CLI has no stdin option.
- `allow_change_held_packages` lets a pin bump move the held package to the new version (`ansible.builtin.apt` docs).
