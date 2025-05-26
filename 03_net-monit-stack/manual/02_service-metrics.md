# Service Metrics

## Goal

Deploy internal service monitoring tools to observe DNS traffic, block unwanted
domains, and track uptime of homelab services.

By the end of this step, Pi-hole will be configured as a local DNS sinkhole
(with Unbound as a recursive resolver), and Uptime Kuma will be monitoring
critical internal services.

## Requirements

- Access to Proxmox UI or CLI to create new LXC/VMs
- Internal IPs and hostnames for services you want to monitor
- Prometheus and Grafana (from [01_node-metrics.md](01_node-metrics.md))
- Optional: router or DHCP server that allows you to point LAN DNS to Pi-hole

## Procedure

1. **Deploy Pi-hole**
   - Create a dedicated LXC container or VM (Debian preferred)
   - Install Pi-hole via official script:  
     `curl -sSL https://install.pi-hole.net | bash`
   - Set the container's IP as a static internal DNS server
   - Configure Pi-hole to log and display DNS query metrics

2. **Add Unbound for recursive DNS**
   - Install Unbound on the same host
   - Configure Pi-hole to forward requests to Unbound instead of public DNS
   - Test resolution and DNS leak behavior

3. **Integrate Pi-hole with Prometheus**
   - Install a Pi-hole exporter (e.g., [ekofr/pihole-exporter](https://github.com/eko/pihole-exporter))
   - Expose metrics for Prometheus scraping (typically on port `9617`)
   - Add scrape config to your Prometheus config

4. **Deploy Uptime Kuma**
   - Create a new VM or container
   - Follow installation instructions for (Uptime Kuma)[https://github.com/louislam/uptime-kuma]
   - Depending on your preference, use Docker or standalone Node.js
   - Configure monitors for key services to track uptime (e.g., Proxmox UI, Grafana, DNS)

5. **Add Prometheus scraping for Uptime Kuma**
   - Kuma has no built-in Prometheus exporter but can send alerts via webhook or push API
   - Alternatively, expose uptime health via API polling or wrapper scripts

## Resources

- [Pi-hole Docs](https://docs.pi-hole.net/)
- [Pi-hole Exporter (Prometheus)](https://github.com/eko/pihole-exporter)
- [Unbound Setup Guide (for Pi-hole)](https://docs.pi-hole.net/guides/dns/unbound/)
- [Uptime Kuma GitHub](https://github.com/louislam/uptime-kuma)
- [Uptime Kuma Docker Install](https://github.com/louislam/uptime-kuma/wiki/Docker)

