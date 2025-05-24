# Network Monitoring Stack

## Goal

Create the following components for comprehensive monitoring of home network activity.

### 1. Pi-hole
- **Purpose**: DNS-level ad/malware blocking + traffic visibility  
- **Benefits**: Lightweight, improves network performance & privacy  
- **Deploy as**: LXC container or VM  

### 2. Netdata
- **Purpose**: Real-time system monitoring (CPU, memory, network, disk)  
- **Benefits**: Beautiful live dashboards per host/container  
- **Deploy as**: Agent on each host or in a central container  

### 3. Prometheus
- **Purpose**: Time-series metric collection  
- **Benefits**: Flexible scraping and querying for metrics  
- **Deploy as**: Central container  

### 4. Grafana
- **Purpose**: Dashboard visualization  
- **Benefits**: Powerful and customizable front-end for Prometheus (and others)  
- **Deploy as**: Container with persistent volume  

### 5. Node Exporter
- **Purpose**: Exposes host metrics to Prometheus  
- **Deploy on**: Each VM/container you want monitored  

## Requirements
List any tools, accounts, or system requirements needed before starting. Use bullets or short phrases.

## Procedure
Ordered list of the exact steps to follow. Keep it clear and actionable.

## Resources
Links to official docs, blog posts, or troubleshooting tips. Use this to back up steps or dive deeper if needed.
