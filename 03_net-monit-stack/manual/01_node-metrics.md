# Node Metrics

## Goal

Deploy local observability agents to individual nodes and configure a central Prometheus + Grafana stack to collect and
visualize system metrics.  By the end of this step, each node should report CPU, memory, disk, and network metrics to a
Prometheus server, and Grafana should display these metrics on a real-time dashboard.

## Requirements

- Two Debian-based nodes with SSH access
  - **Suggestion**: create VMs following the procedure outlined in [`02_ansible-control-node/01_create-debian-vm.md`](../../02_ansible-ctl-node/01_create-debian-vm.md)
  - Create a dev VM to serve as a monitored node
      - Recommended resource allocation for dev VM: 2 cores, 6 GB (6144 MiB) RAM, and 32 GB disk space
  - Create a second VM to host Prometheus
      - Recommended resource allocation for Prometheus VM: 2 cores, 4 GB (4096 MiB) RAM, and 32 GB disk space
      - Use `prometheus` as the VM name and hostname for clarity
- WAN access

## Procedure

### 1. Install Node Exporter on each monitored node
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

### 2. Install Prometheus on a dedicated VM
- SSH into the Prometheus VM.
- Download and extract the latest Prometheus release:
 ```bash
 curl -LO https://github.com/prometheus/prometheus/releases/download/v3.4.1/prometheus-3.4.1.linux-amd64.tar.gz
 ```
 ```bash
 mkdir -p prometheus && tar -xzf prometheus-*-amd64.tar.gz -C prometheus --strip-components=1 && cd prometheus
 ```
- The following steps will set up Prometheus to run as a systemd service so that it is boot-persistent. First, move
  binaries to system path:
 ```bash
 sudo mv ~/prometheus/{prometheus,promtool} /usr/local/bin/
 ```
- Next, create Prometheus user:
 ```bash
 sudo useradd --no-create-home --shell /bin/false prometheus
 ```
- Create config and data directories:
 ```bash
 sudo mkdir -p /etc/prometheus /var/lib/prometheus
 ```
- Copy the Prometheus config file to `etc/`:
 ```bash
 sudo cp ~/prometheus/prometheus.yml /etc/prometheus/
 ```
- Set permissions:
 ```bash
 sudo chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus
 ```
- Create systemd unit file:
 ```bash
 sudo vim /etc/systemd/system/prometheus.service
 ```
- Add the following content:
 ```ini
 [Unit]
 Description=Prometheus Monitoring
 Wants=network-online.target
 After=network-online.target
 
 [Service]
 User=prometheus
 Group=prometheus
 Type=simple
 ExecStart=/usr/local/bin/prometheus \
   --config.file=/etc/prometheus/prometheus.yml \
   --storage.tsdb.path=/var/lib/prometheus/
 
 [Install]
 WantedBy=multi-user.target
 ```
- Reload systemd and start the new Prometheus service:
 ```bash
 sudo systemctl daemon-reexec
 sudo systemctl daemon-reload
 sudo systemctl enable --now prometheus
 ```
- Verify service is up:
 ```bash
 systemctl status prometheus
 ```
- In a desktop environment on a machine in your local network, use a web browser to check output. The service should be up on port 9090:
 ```url
 http://[PROMETHEUS_IP]:9090
 ```
- The following steps will add other nodes as monitored targets. Update `/etc/prometheus/prometheus.yml` with the following, defining each monitored node in the list of `targets` under the `node_exporter_targerts` job. **Note**: each monitored node must be running the Prometheus node exporter, as installed in the previous section:
 ```yaml
scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
        labels:
          app: 'prometheus'

  - job_name: 'node_exporter_targets'
    static_configs:
      - targets: ['[DEV_VM]:9100']  
        labels:
          app: 'node_exporter'
 ```
- Restart Prometheus service:
 ```bash
 sudo systemctl restart prometheus
 ```
- Back in a desktop environment, confirm that the newly added target is producing output:
 ```
 http://[PROMETHEUS_IP]:9090
 ```
- This node should remain online to scrape and store time-series metrics continuously.

### 3. Configure firewall rules

The following steps will use [`ufw` (Uncomplicated
Firewall)](https://documentation.ubuntu.com/server/how-to/security/firewalls/index.html) to ensure that only the
Prometheus node can access the target's broadcasted metrics. In addition, firewall rules will limit what other nodes on
the local network can access the Prometheus node. This restriction prevents other LAN devices from accessing Prometheus
data without explicit confirmation.

**Note**: use static IPs or DHCP reservations. `ufw` rules can break if DHCP assigns different IPs to the nodes involved.

#### Prometheus node

- Install `ufw`:
  ```bash
  sudo apt install -y ufw
  ```

- Allow SSH so you don't lock yourself out:
  ```bash
  sudo ufw allow OpenSSH
  ```
  
- Allow only your desktop environment (e.g., laptop) to access Prometheus:
  ```bash
  sudo ufw allow proto tcp from [DESKTOP_IP] to any port 9090
  ```

- Deny all other access to Prometheus. **Note**: you will need to use the preceding `ufw allow` command to allow any other nodes to access the Prometheus node.
  ```bash
  sudo ufw deny proto tcp from any to any port 9090
  ```

- Enable and verify:
  ```bash
  sudo ufw enable
  ```
  ```bash
  sudo ufw status verbose
  ```

#### Monitored target node

- Install `ufw`:
  ```bash
  sudo apt install -y ufw
  ```

- Allow SSH so you don't lock yourself out:
  ```bash
  sudo ufw allow OpenSSH
  ```

- Allow only the Prometheus VM to access Node Exporter:
  ```bash
  sudo ufw allow from [PROMETHEUS_IP] to any port 9100 proto tcp
  ```

- Deny all other access to Node Exporter:
  ```bash
  sudo ufw deny 9100
  ```

- Enable and verify:
  ```bash
  sudo ufw enable
  ```
  ```bash
  sudo ufw status verbose
  ```

### 4. Install Grafana
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

### 5. Install Netdata on each node
   - Install Netdata:
     ```bash
     bash <(curl -Ss https://my-netdata.io/kickstart.sh)
     ```
   - Access the dashboard at:
     ```
     http://<node-ip>:19999
     ```
   - Optionally expose metrics to Prometheus by enabling the Prometheus plugin in Netdata’s config.

### 6. Verify Metrics Collection
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

