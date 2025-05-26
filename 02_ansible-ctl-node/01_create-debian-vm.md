# Create Debian VM in Proxmox

## Goal

Create a virtual machine on the Proxmox host that will serve as the Ansible control node.

## Requirements

- Debian ISO uploaded to Proxmox
- Proxmox web UI access
- Basic VM specs chosen (CPU, RAM, disk)

## Procedure

1. Open Proxmox web interface and create new VM
2. Assign name: `ansible-ctl`
3. Mount Debian ISO
4. Configure hardware:
   - 2 vCPUs
   - 2 GB RAM
   - 16–20 GB disk (VirtIO or SCSI recommended)
5. Select `VirtIO` for disk and network interfaces
6. Start VM and install Debian (see next guide)

## Resources

- [Proxmox VE: Creating VMs](https://pve.proxmox.com/wiki/Virtual_Machines)
- [Debian Official ISO Downloads](https://www.debian.org/distrib/)
- [Proxmox Recommended Disk and NIC Settings](https://pve.proxmox.com/wiki/Performance_Tweaks)
- [Debian Installation Guide](https://www.debian.org/releases/bookworm/amd64/index.en.html)

