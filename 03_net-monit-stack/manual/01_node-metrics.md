# Node Metrics

## Goal

Deploy local observability agents to individual nodes and configure a central Prometheus + Grafana stack to collect and
visualize system metrics.  By the end of this step, each node should report CPU, memory, disk, and network metrics to a
Prometheus server, and Grafana should display these metrics on a real-time dashboard.

## Requirements

- A Debian-based node with SSH access
  - **Suggestion**: create a dev VM following the procedure outlined in [`02_ansible-control-node/01_create-debian-vm.md`](../02_ansible-control-node/01_create-debian-vm.md)
  - Recommended resource allocation for dev VM: 2 cores, 6 GB (6144 MiB) RAM, and 32 GB disk space.
- WAN access

## Procedure

1. **Install Node Exporter on each monitored node**
   - SSH into the dev VM or other monitored node running Debian-based Linux.
   - Install Node Exporter, a lightweight Prometheus client that exposes hardware and OS metrics:
     ```bash
     sudo apt install -y prometheus-node-exporter
     ```
   - Enable and confirm the Node Exporter is `active (running)`:
     ```bash
     sudo systemctl enable --now prometheus-node-exporter && systemctl status prometheus-node-exporter
     ```
   - In a web browser on the local network, confirm metrics are exposed at:
     ```
     http://[DEV_IP]:9100/metrics
     ```

2. **Install Prometheus on a dedicated VM or container**
   - First, create a dedicated Prometheus VM using the same procedure outlined in
     `[02_ansible-ctl/01_create-vm.md](../02_ansible-ctl/01_create-vm.md)`
     - Recommended resource allocation for Prometheus VM: 2 cores, 4 GB (4096 MiB) RAM, and 32 GB disk space.
     - This node should remain online to scrape and store time-series metrics continuously.
   - SSH into the Prometheus VM.
   - Download and extract the latest Prometheus release:
     ```bash
     curl -LO https://github.com/prometheus/prometheus/releases/latest/download/prometheus-*-amd64.tar.gz
     ```
     ```bash
     tar -xzf prometheus-*-amd64.tar.gz && cd prometheus-*/
     ```
   - Define targets in `prometheus.yml` under the `scrape_configs` section:
     ```yaml
     scrape_configs:
       - job_name: 'node_exporter_targets'
         static_configs:
           - targets: ['[DEV_IP]:9100']
     ```
   - Start Prometheus:
     ```bash
     ./prometheus --config.file=prometheus.yml
     ```
   - Access the UI at:
     ```
     http://[PROMETHEUS_IP]:9090
     ```

3. **Install Grafana**
   - Install Grafana from official sources or APT (Debian has it in backports):
     ```bash
     sudo apt install -y grafana
     sudo systemctl enable --now grafana-server
     ```
   - Access Grafana at:
     ```
     http://<grafana-ip>:3000
     ```
   - Log in (default: admin/admin), add Prometheus as a data source, and import a basic Node Exporter dashboard from [Grafana Dashboards](https://grafana.com/grafana/dashboards).

4. **(Optional) Install Netdata on each node**  
   - Install Netdata:
     ```bash
     bash <(curl -Ss https://my-netdata.io/kickstart.sh)
     ```
   - Access the dashboard at:
     ```
     http://<node-ip>:19999
     ```
   - Optionally expose metrics to Prometheus by enabling the Prometheus plugin in Netdata’s config.

5. **Verify Metrics Collection**  
   - In Prometheus, confirm that all targets are listed and healthy at:  
     ```
     http://<prometheus-ip>:9090/targets
     ```
   - In Grafana, ensure your dashboards reflect real-time data for all monitored nodes.

## Resources

- [Prometheus Node Exporter Docs](https://prometheus.io/docs/guides/node-exporter/)
- [Prometheus Getting Started](https://prometheus.io/docs/prometheus/latest/getting_started/)
- [Grafana Installation Docs](https://grafana.com/docs/grafana/latest/setup-grafana/installation/)
- [Netdata Installation](https://learn.netdata.cloud/docs/agent/packaging/installer/)
- [Grafana Dashboard: Node Exporter Full](https://grafana.com/grafana/dashboards/1860-node-exporter-full/)

