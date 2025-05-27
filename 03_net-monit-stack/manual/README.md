# Network Monitoring Stack: Manual Procedure

## Goal

Deploy a set of modular tools that provide real-time observability, service uptime tracking, and system-wide diagnostics
across the homelab environment. By the end of this phase, the homelab should have live dashboards, metrics collection,
and optional logging for internal services and external connectivity.

## Requirements

- Proxmox VE with LXC/VM support
- Debian-based containers or VMs for monitoring services
- Access to internal node IPs (for scraping/exporting metrics)
- Optional: router/switches that support SNMP

## Procedure

This phase is divided into three progressive layers of observability:

1. **[Node Metrics](01_node-metrics.md)**  
   - Install local metrics agents and set up a Prometheus + Grafana stack to track per-node system performance.

2. **[Service Metrics](02_service-metrics.md)**  
   - Monitor internal services like DNS and app uptime using Pi-hole, Unbound, and Uptime Kuma.

3. **[System Metrics](03_system-metrics.md)**  
   - Extend observability to WAN performance, endpoint reachability, and external network interactions using Speedtest
     CLI, Blackbox Exporter, and SNMP Exporter.

## Resources

- [Prometheus Docs](https://prometheus.io/docs/introduction/overview/)
- [Grafana Docs](https://grafana.com/docs/)
- [Netdata Docs](https://learn.netdata.cloud/docs/)
- [Pi-hole Docs](https://docs.pi-hole.net/)
- [Uptime Kuma GitHub](https://github.com/louislam/uptime-kuma)
- [Loki Docs](https://grafana.com/docs/loki/latest/)
- [SNMP Exporter Docs](https://github.com/prometheus/snmp_exporter)
- [Blackbox Exporter Docs](https://github.com/prometheus/blackbox_exporter)

