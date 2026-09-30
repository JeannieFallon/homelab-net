# homelab-net

A self-hosted home network and monitoring stack running on a single Proxmox hypervisor, configured from a dedicated Ansible control node.

## Language

### Infrastructure

**Proxmox host**:
The bare-metal machine (an Intel NUC) that runs Proxmox VE and hosts every VM in the lab.
_Avoid_: node, server, NUC (except when describing the hardware itself)

**Control node**:
The VM that runs Ansible and applies playbooks to every other VM.
_Avoid_: Ansible node, ansible-ctl node, controller

### Monitoring

**Monitored host**:
Any VM that runs node exporter and has its metrics scraped by Prometheus.
_Avoid_: node, monitored node, target node, dev VM, endpoint

**Monitoring server**:
The single VM that runs both Prometheus and Grafana. "Prometheus" and "Grafana" name the services, never a machine.
_Avoid_: Prometheus node, Prometheus VM, Grafana VM, Prometheus server

**Host metrics**:
Resource usage of a monitored host: CPU, memory, disk, and network.
_Avoid_: endpoint monitoring, node metrics (except as the walkthrough's title)
