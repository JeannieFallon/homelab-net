# Node Metrics

## Goal

Deploy local observability agents to individual nodes and configure a central Prometheus + Grafana stack to collect and
visualize system metrics.  By the end of this step, each node should report CPU, memory, disk, and network metrics to a
Prometheus server, and Grafana should display these metrics on a real-time dashboard.

## Requirements

- Functional Ansible control node
- At least one target node (VM or container) with SSH access
- Basic understanding of Ansible inventory and playbook execution
- Debian-based OS on target nodes
- Internet access for package installation

## Procedure

1. **Install Node Exporter on each monitored node**
   - Use Ansible or manual steps to install `prometheus-node-exporter`
   - Enable and start the service
   - Confirm that metrics are exposed on port `9100`

2. **Install Prometheus on a dedicated VM or container**
   - Download and extract the latest Prometheus release
   - Define scrape targets for each node running Node Exporter
   - Start the Prometheus service and verify the web UI (`http://<prometheus-ip>:9090`)

3. **Install Grafana**
   - Install Grafana on the same host as Prometheus or on a separate node
   - Log in to Grafana (`http://<grafana-ip>:3000`)
   - Add Prometheus as a data source
   - Import a basic Node Exporter dashboard

4. **(Optional) Install Netdata on each node**
   - Install Netdata for per-node real-time dashboards (`http://<node-ip>:19999`)
   - Optionally configure Netdata to expose Prometheus-compatible metrics

5. **Verify system metrics collection**
   - Confirm Prometheus is scraping all configured targets
   - Confirm Grafana dashboards display node metrics correctly

## Resources

- [Prometheus: Node Exporter](https://github.com/prometheus/node_exporter)
- [Prometheus Download](https://prometheus.io/download/)
- [Grafana Installation](https://grafana.com/docs/grafana/latest/installation/)
- [Grafana Dashboards: Node Exporter](https://grafana.com/grafana/dashboards/)
- [Netdata Installation](https://learn.netdata.cloud/docs/agent/packaging/installer)

