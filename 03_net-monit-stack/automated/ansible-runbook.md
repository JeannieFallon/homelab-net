# Ansible Runbook – Network Monitoring Stack

This runbook describes how to deploy the homelab network monitoring stack using Ansible-based automation. It assumes you have a functioning Ansible control node and access to the relevant target nodes.

## Goal

Automate the installation and configuration of observability tools across your homelab using Ansible. This includes node-level metrics, internal service monitoring, and system-wide diagnostics.

## Requirements

- A working Ansible control node
- Inventory file with target hosts defined
- SSH access from control node to all targets
- Debian-based systems with internet access
- Playbooks and roles located in `homelab-net/ansible/`

## Procedure

This deployment is divided into three phases that mirror the manual setup process:

### Phase 1: Node Metrics

Deploy system-level monitoring agents to each node and set up centralized collection and visualization.

Tools:
- Netdata
- Node Exporter
- Prometheus
- Grafana

### Phase 2: Service Metrics

Deploy internal service monitoring tools to gain visibility into DNS traffic and service uptime.

Tools:
- Pi-hole + Unbound
- Uptime Kuma

### Phase 3: System Metrics

Monitor overall homelab health and external connectivity, including WAN diagnostics and endpoint reachability.

Tools:
- Blackbox Exporter
- SNMP Exporter
- Speedtest CLI
- Loki + Promtail (optional)

## Execution

Use Ansible to execute the appropriate playbooks for each phase.

Example workflow:
1. Validate inventory access:
   ```bash
   ansible -i inventory.ini all -m ping
   ```

2. Execute a phase-specific playbook (to be defined):
   ```bash
   ansible-playbook -i inventory.ini [PLAYBOOK].yml
   ```

## Notes

The structure of this automation mirrors the manual deployment steps in `manual/`.
