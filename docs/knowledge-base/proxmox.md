# Proxmox VE

## Description

Proxmox Virtual Environment (Proxmox VE) is an open-source server management
platform for enterprise virtualization. It tightly integrates KVM hypervisor and
LXC, software-defined storage, and networking functionality on a single
platform. With the integrated web-based user interface, you can manage VMs and
containers, high availability for clusters, or the integrated disaster recovery
tools with ease.

## Installation

Proxmox VE is a bare-metal installer. See the [Proxmox set-up guide](../../01_proxmox-setup/) for guided walkthrough.

### Version Upgrade

- Check current version and system kernel:

      pveversion && uname -r

- If using free version, make sure that enterprise repo is commented out and disabled:

      root@pve:~# cat /etc/apt/sources.list.d/pve-enterprise.list 
      # deb https://enterprise.proxmox.com/debian/pve bookworm pve-enterprise

- If Proxmox is running as a single node, you can likewise disable Ceph repos:

      root@pve:~# cat /etc/apt/sources.list.d/ceph.list 
      #  deb https://enterprise.proxmox.com/debian/ceph-quincy bookworm enterprise
      . . .

- Make sure you've got the no-subscription repo:

      root@pve:~# cat /etc/apt/sources.list.d/pve-install-repo.list 
      deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription

- Run update & distribution upgrade so that all installed packages are upgraded as well as any added/removed packages to satisfy dependency changes:

      apt update && apt dist-upgrade -y
      
- Check if reboot required:

      [ -f /var/run/reboot-required ] && echo "REBOOT NEEDED" || echo "no reboot required"

- Confirm that running kernel version listed by `uname` is the highest available kernel version in `/boot`. If not, reboot to apply kernel update:

      uname -r && ls /boot/vmlinuz-*

- **If reboot is needed**: check what VMs and LXC containers are running. Either shut down all running items, or Proxmox will automatically stop during reboot:

      qm list && pct list

- Verify upgrade by confirming new Proxmox version, running kernel, all system services back up, and storage back-ends all online:

      pveversion && uname -r && systemctl --failed && pvesm status

- Purge unneeded packages:

      apt autoremove

- Check for any errors in this boot's log:

      journalctl -p err -b


## Cheatsheet: Common CLI Commands

Proxmox provides a set of powerful command-line tools to manage your virtualization environment.

### Proxmox Container (LXC) Management (`pct`)

-   **List all containers:**
    ```bash
    pct list
    ```

-   **Start a container:**
    ```bash
    pct start <vmid>
    ```

-   **Stop a container:**
    ```bash
    pct stop <vmid>
    ```

-   **Enter a container (get a shell):**
    ```bash
    pct enter <vmid>
    ```

-   **Create a new container:**
    ```bash
    pct create <vmid> <template> --hostname <name> --net0 name=eth0,bridge=vmbr0,ip=dhcp
    ```

### Proxmox VM (KVM) Management (`qm`)

-   **List all VMs:**
    ```bash
    qm list
    ```

-   **Start a VM:**
    ```bash
    qm start <vmid>
    ```

-   **Stop a VM:**
    ```bash
    qm stop <vmid>
    ```

-   **Shutdown a VM gracefully:**
    ```bash
    qm shutdown <vmid>
    ```

-   **Clone a VM:**
    ```bash
    qm clone <vmid> <new-vmid> --name <new-name>
    ```

### Proxmox Shell (`pvesh`)

`pvesh` is a tool that allows you to interact with the Proxmox API from the command line.

-   **Get cluster status:**
    ```bash
    pvesh get /cluster/status
    ```

-   **List all nodes:**
    ```bash
    pvesh get /nodes
    ```

-   **List storage on a specific node:**
    ```bash
    pvesh get /nodes/<node-name>/storage
    ```
