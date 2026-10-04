# Roadmap

Phase-level plan for this repo. Individual tasks are tracked in
[GitHub Issues](https://github.com/JeannieFallon/homelab-net/issues).

## Phase 1: Playbooks for the existing manual procedures

Convert the completed manual procedures into Ansible playbooks and roles,
targeting Debian 13 ([spec #10](https://github.com/JeannieFallon/homelab-net/issues/10)):

- Ansible control node
- Node exporter
- Prometheus
- Grafana

VMs are cloned from a hand-built Debian 13 cloud-init template, which gets its
own walkthrough. The Debian 12 walkthroughs stay frozen as the record of the
manual work, and the roles and ADRs become the source of truth.

The repo is not renamed and the README is not rewritten during this phase.

## Phase 2: Validation on fresh VMs

Run the Phase 1 playbooks on the Proxmox host (Intel NUC) against VMs freshly
cloned from the Debian 13 template, not the manually built ones. Everything is
rebuilt: the control node, the monitoring server, and two workload VMs. The
manually built VMs, including the old control node, are snapshotted and then
purged once the new control node can reach its targets.

Pass criteria:

- The first run converges without errors.
- A second run reports `changed=0` on every host (`scripts/converge-check.sh`).
- The verification play passes, and a manual look confirms that Grafana shows
  node exporter data from the new VMs.

## Phase 3: Rescope as `infra-base`

- Rename the repo to `infra-base`.
- Rewrite the README to describe a reproducible base configuration for a
  Proxmox homelab: Debian VM provisioning, Ansible control, and
  Prometheus/Grafana observability. Keep it general so that function-specific
  stacks can build on it.
- Move Pi-hole, Unbound, Uptime Kuma, blackbox exporter, SNMP exporter, and
  Loki to a "Deferred to infra-net" section.
- Note that Promtail is end-of-life. Any future log shipping uses Grafana
  Alloy.

## Deferred

- VM provisioning as code (OpenTofu with the `bpg/proxmox` provider)
- Molecule testing (ufw, systemd, and the QEMU guest agent fight containers)
- TLS for Grafana behind a reverse proxy

## Out of scope

- Agent sandboxing (planned as a separate repo)
- The Raspberry Pi build
- All network monitoring tools
