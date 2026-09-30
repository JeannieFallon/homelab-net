# Prometheus and Grafana share one monitoring server

The original node-metrics walkthrough put Prometheus and Grafana on separate VMs. We run both on a single monitoring server instead. For a single-user homelab the second VM adds resource cost and firewall rules without adding resilience, and co-location lets Prometheus listen on localhost only, so Grafana on port 3000 is the only monitoring service exposed to the LAN.

The two services are still separate Ansible roles, so splitting them onto their own VMs later is a change to the play, not to the roles. The cost of reversing is migrating Prometheus's stored data and reopening port 9090 between VMs.
