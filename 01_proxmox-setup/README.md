# Proxmox Set-up

## Goal
Install Proxmox hypervisor on an Intel NUC with web interface accessible to other machines on local network.

## Requirements

The following equipment was used to install and configure Proxmox:

### Intel NUC

- **Purpose**: Bare-metal Proxmox hypervisor host
- **Type**: Small form-factor mini-PC
- **Specs**:
    - CPU: 64-bit, multi-core Intel processor with virtualization support
    - RAM: 32GB DDR4 (SO-DIMM)
    - Storage: NVMe SSD
    - Networking: Gigabit Ethernet

### Windows Laptop
- **Purpose**: Used to download the Proxmox ISO and flash it to a USB drive
- **OS**: Windows 10 or 11
- **Software**: Rufus for creating a bootable USB drive

### USB Drive
- **Purpose**: Bootable media for installing Proxmox on the NUC
- **Specs**:
    - Type: USB-A (must fit into the NUC’s standard USB port)
    - Speed: USB 3.0 or higher is recommended for faster ISO flashing and installation
    - Capacity: Minimum 8GB
        - **Note**: any pre-existing data on drive will be erased
    - Format: FAT32 or NTFS (formatted by flashing tool)

## Procedure

This procedure is divided into three logical stages based on the machine used:

1. **Create Proxmox ISO Installer** (`01_proxmox-iso.md`)
   - On a separate machine (e.g., Windows laptop), download the Proxmox VE ISO and flash it to a USB drive using a tool like Rufus or Balena Etcher.

2. **Install Proxmox on NUC** (`02_nuc-install.md`)
   - With physical access to the Intel NUC, configure the BIOS, boot from the USB installer, and complete the Proxmox installation on the internal drive.

3. **Access Web UI and Configure Hypervisor** (`03_web-ui.md`)
   - From another machine on the same network, connect to the Proxmox web interface to verify the installation and complete initial configuration steps (e.g., storage, networking, subscription settings).

## Resources

- [Learn Linux TV: Proxmox Full Course](https://youtube.com/playlist?list=PLT98CRl2KxKHnlbYhtABg6cF50bYa8Ulo&si=OG2KcEjnQrU8l_qh)
- [Mark Watt Tech: Home Assistant PROXMOX Install and Setup (With NUC Alternative)](https://youtu.be/PrKQkI53xys?si=JC_IZlWFhL1uaeTq)
- [NetworkChuck: Virtual Machines Pt. 2 (Proxmox install w/ Kali Linux)](https://youtu.be/_u8qTN3cCnQ?si=UvFvcBShyHxs4Y3O)
