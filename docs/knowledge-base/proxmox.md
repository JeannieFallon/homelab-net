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
