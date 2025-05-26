# System Metrics

## Goal

Extend observability to cover homelab-wide uptime, WAN performance, and
external service reachability. Monitor device-level stats, external endpoints,
and log collection for system-wide insights.

By the end of this step, you will be able to observe the performance of your
entire infrastructure and its interaction with the wider internet.

## Requirements

- Functional Prometheus and Grafana stack
- Internal node IPs or service URLs to monitor
- Optional SNMP-enabled devices (e.g., router, switch, NAS)
- Optional container or VM for running exporters or CLI tools

## Procedure

1. **Install Blackbox Exporter**
   - Deploy on the same node as Prometheus or a dedicated container
   - Configure probe modules (HTTP, HTTPS, TCP, ICMP, DNS)
   - Add Prometheus scrape config for targets (e.g., internal services, external endpoints)

2. **Install SNMP Exporter (optional)**
   - Deploy SNMP exporter on the Prometheus node or separate container
   - Generate or download SNMP config for target devices
   - Test reachability to SNMP-enabled devices (e.g., switches, routers)
   - Add Prometheus scrape configs for SNMP jobs

3. **Install Speedtest CLI**
   - Install on any node with internet access (e.g., control node or metrics host)
   - Set up a cron job or systemd timer to run periodic speed tests
   - Log results to file or expose via a wrapper script to Prometheus

4. **Install Loki + Promtail (optional)**
   - Deploy Loki as a container or VM
   - Install Promtail on each node to ship logs
   - Add Grafana Loki as a data source for log correlation alongside metrics
   - Configure Promtail to monitor syslog, journald, or app logs

5. **Verify end-to-end system visibility**
   - Confirm Prometheus is scraping exporters correctly
   - Confirm Grafana dashboards are populated with system-wide trends
   - Optionally configure alerting rules for WAN issues or service unavailability

## Resources

- [Prometheus: Blackbox Exporter](https://github.com/prometheus/blackbox_exporter)
- [Prometheus: SNMP Exporter](https://github.com/prometheus/snmp_exporter)
- [Speedtest CLI](https://www.speedtest.net/apps/cli)
- [Grafana Loki Overview](https://grafana.com/oss/loki/)
- [Promtail Setup Guide](https://grafana.com/docs/loki/latest/clients/promtail/)
- [Grafana Alerting](https://grafana.com/docs/grafana/latest/alerting/)

