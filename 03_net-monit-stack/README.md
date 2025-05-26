# Network Monitoring Stack

This module contains documentation and tooling for deploying a self-hosted network monitoring stack in a homelab
environment. Depending upon your set-up and preferences, you can choose between the automated and manual options listed
below.

## Options

### `automated/`: Ansible-Based Deployment

If you already have a working [Ansible](https://www.ansible.com/) control node, you can use the Ansible runbook to
automatically deploy and configure the full monitoring stack. This approach is faster, repeatable, and designed for
infrastructure-as-code workflows.

Start here if:
- You are familiar with Ansible
- You want to minimize manual configuration
- You’re planning to scale or iterate on this set-up over time

See `[automated/README.md](automated/README.md)` for more details.

---

### `manual/`: Step-by-Step Manual Deployment

If you prefer to install and configure components individually, the manual procedure walks through each tool in
isolation with detailed set-up instructions.

Start here if:
- You are new to Prometheus, Grafana, or observability tooling
- You want to understand how everything works under the hood
- You're setting up a one-off or learning-focused environment

See `[manual/README.md](manual/README.md)` for more details.

---

## Tools Covered

All workflows ultimately support the same toolset, including:

- Netdata
- Node Exporter
- Prometheus
- Grafana
- Pi-hole + Unbound
- Uptime Kuma
- Blackbox Exporter
- SNMP Exporter
- Speedtest CLI
- Loki + Promtail (optional)
