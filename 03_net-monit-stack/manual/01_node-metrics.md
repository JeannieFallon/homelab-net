# Node Metrics

## Goal

Deploy local observability agents to individual nodes and configure a central Prometheus + Grafana stack to collect and
visualize system metrics.  By the end of this step, each node should report CPU, memory, disk, and network metrics to a
Prometheus server, and Grafana should display these metrics on a real-time dashboard.

## Requirements

- Three Debian-based nodes with SSH access
  - **Suggestion**: create VMs following the procedure outlined in [`02_ansible-control-node/01_create-debian-vm.md`](../../02_ansible-ctl-node/01_create-debian-vm.md)
  - Create a dev VM to serve as a monitored node
      - Recommended resource allocation for dev VM: 2 cores, 6 GB (6144 MiB) RAM, and 32 GB disk space
      - User whatever hostname you prefer
  - Create a second VM to host Prometheus
      - Recommended resource allocation for Prometheus VM: 2 cores, 4 GB (4096 MiB) RAM, and 32 GB disk space
      - Use `prometheus` as the VM name and hostname for clarity
  - Create a third VM to host Grafana
      - Recommended resource allocation for Grafana VM: 2 cores, 2 GB (2048 MiB) RAM, and 16 GB disk space (thin provisioned)
        - **Note**: set `Display: Default`
      - Use `grafana` as the VM name and hostname for clarity
- Secondary monitor or TV connected via HDMI to the Intel NUC 

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

### 2. Install Prometheus on dedicated VM
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

- By default, deny all incoming traffic:
  ```bash
  sudo ufw default deny incoming
  ```

- By default, allow all outgoing traffic:
  ```bash
  sudo ufw default allow outgoing
  ```

- Set an exception to allow incoming traffic from your desktop environment (e.g., laptop):
  ```bash
  sudo ufw allow from [DESKTOP_IP] to any port 9090 proto tcp
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

- By default, deny all incoming traffic:
  ```bash
  sudo ufw default deny incoming
  ```

- By default, allow all outgoing traffic:
  ```bash
  sudo ufw default allow outgoing
  ```

- Allow SSH so you don't lock yourself out:  
  ```bash
  sudo ufw allow OpenSSH
  ```

- Allow Prometheus server to scrape node exporter on port 9100:
  ```bash
  sudo ufw allow from [PROMETHEUS_IP] to any port 9100 proto tcp
  ```

- Enable the firewall:
  ```bash
  sudo ufw enable
  ```

- Verify status:
  ```bash
  sudo ufw status numbered
  ```

### 4. Install Grafana on dedicated VM

This VM will run a minimal graphical environment that boots directly into a fullscreen Grafana dashboard on your TV via HDMI.

#### Install Minimal Desktop Environment  

- SSH into the Grafana VM.

- Update the system:  
  ```bash
  sudo apt update && sudo apt upgrade -y
  ```

- Install a minimal desktop environment:  
  ```bash
  sudo apt install -y xorg openbox firefox-esr lightdm
  ```

- Hide the mouse cursor when idle:  
  ```bash
  sudo apt install -y unclutter
  ```

- Install Grafana:
  ```bash
  sudo apt install -y grafana
  ```

- Start service:
  ```bash
  sudo systemctl enable --now grafana-server
  ```

- Grafana should now be accessible at `http://localhost:3000` on a web browser inside the VM.

#### Create a Dedicated Kiosk User
- Add a new user:  
  ```bash
  sudo adduser kiosk-user
  ```

#### Enable Auto-login with LightDM
- Edit the LightDM configuration:
  ```bash
  sudo vim /etc/lightdm/lightdm.conf
  ```

- Add the following lines:  
  ```ini
  [Seat:*]
  autologin-user=kiosk-user
  ```

#### Configure auto-launch of kiosk browser

- Switch to the `kiosk-user`:
  ```bash
  sudo su - kiosk-user
  ```

- Create openbox directory:
  ```bash
  mkdir -p /home/kiosk-user/.config/openbox
  ```

- Create autostart file:
  ```bash
  vim /home/kiosk-user/.config/openbox/autostart
  ```

- Add the following:
  ```bash
  unclutter &
  firefox-esr --kiosk http://localhost:3000 &
  ```

#### Optional: Lock down networking  
- Restrict `ufw` rules so only Prometheus can reach this VM  
- Block inbound access to `3000` from the rest of the LAN  
- Optionally allow your laptop's IP to access Grafana for configuration


#### Display Output to TV  
- Ensure your Proxmox host outputs video over HDMI  
- This kiosk VM will boot into a full-screen Firefox window on login  
- If no output appears:
  - Check GPU passthrough settings (optional)
    - Or use Proxmox’s console and mirror the display

#### Test the Kiosk VM  
- Reboot the VM  
- Confirm that it automatically logs in and displays the Grafana dashboard in fullscreen kiosk mode  
- Make sure the TV is receiving and displaying the output as expected

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

