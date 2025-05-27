# Create Debian VM in Proxmox

## Goal

Create a virtual machine on the Proxmox host that will serve as the Ansible control node.

## Requirements

- Proxmox VE server with WAN access
- Access to Proxmox web interface

## Procedure

1. **Download the Debian ISO**
   - Visit the [official Debian download page](https://www.debian.org/download)
   - Choose the **64-bit PC netinst ISO**: `debian-[VERSION]-amd64-netinst.iso`
   - For most homelab use cases, the minimal **netinst** ISO is sufficient.

2. **Upload the ISO to Proxmox**
   - In the Proxmox web UI, select "Server View" in the upper left
   - Navigate to: `pve > local (pve) > storage > ISO Images`
        - **Note**: substitute your node's name if you chose something other than `pve`
   - Click **Upload**, then select the Debian ISO you downloaded
        - **Optional**: choose a hash algorithm to verify uploaded ISO, either against a hash generated locally
          from the file or a hash listed on the ISO's download page.
   - Once the upload is complete, you should see the ISO listed on ISO Images tab.

3. **Create the VM**
   - In the Proxmox web UI, click **Create VM** in the upper right
   - Use the following options to configure the VM:
       - **General**
         - Node: Select your Proxmox node (likely `pve`)
         - VM ID: Default value is sufficient unless you have designed an ID schema for organization
         - Name: `ansible-ctl`
         - Check the box for *Advanced* options at the bottom of the tab
       - **OS**
         - ISO Image: Select the Debian ISO uploaded in the previous step
         - Guest OS: Choose `Linux`
         - Version: `5.x - 2.6 Kernel` (safe default for Debian Bookworm)
       - **System**
         - Graphic Card: Default
         - Machine: `q35`
           - `q35` provides a modern virtual chipset with PCIe and UEFI support
         - BIOS: Select **OVMF (UEFI)**
           - **Note**: this assumes that your hardware supports UEFI, like the Intel NUC that was used to stand up Proxmox
             in the previous section
         - EFI Storage: Choose available EFI storage location, likely `local-lvm`
           - **Note**: you can confirm available EFI storage at `Datacenter > Storage > local-lvm > Content`
         - SCSI Controller: Use **VirtIO SCSI Single** for optimal performance
           - **Note**: For a storage-heavy VM to be used as a media server, NAS, or database node, use plain VirtIO SCSI
         - Check **QEMU Agent** to install the guest agent later
       - **Disks**
         - Bus/Device: `SCSI`
           - **Note**: Although VirtIO Block may be technically faster in raw I/O benchmarks, SCSI paired with VirtIO SCSI
             is a better choice to support hotplugging, more flexibility for back-ups and snapshots, and better integration
             with QEMU Guest Agent features
         - Disk size: 32 GiB
         - Cache: `Default (no cache)`
         - Storage: Select your preferred storage pool
       - **CPU**
         - Socket: 1
         - Cores: 2
         - Type: use `host` to mirror the physical CPU for maximum performance
           - **Note**: ideal for single-node homelabs, but not portable across hosts
       - **Memory**
         - Memory: 4096 MB (4 GB)
         - Uncheck box for *Ballooning Device*
           - **Note**: you can enable if you want dynamic memory control
       - **Network**
         - Bridge: Default (typically `vmbr0`)
         - Model: `VirtIO (paravirtualized)`
         - MAC address: Leave default unless you need a reserved one
         - Uncheck box for *Firewall*
       - **Confirm**
         - Review all settings
         - Click **Finish** to create the VM

4. **Start VM and install Debian**
    - In the Proxmox web UI, select the new `ansible-ctl` VM
    - Navigate to the *Console* tab and power on the VM
    - Once the VM boots, choose the "Graphical install" option
    - The following installation options are recommended for a lightweight, CLI-based Debian server environment:
       - **Language and Locale**
          - Select your preferred language and location
       - **Configure the network**
          - Hostname: `ansible-ctl`
              - **Note**: match the VM name for consistent inventory and DNS mapping
          - Domain name: `local`
              - **Note**: this gives the VM an FQDN of `ansible-ctl.local`, which improves internal DNS or mDNS
                resolution on a LAN, ensures FQDN consistency for tools like Netdata or Prometheus, and helps with
                log clarity and system identification
       - **User and Passwords**
            - Set a strong root password
            - Create a non-elevated user
       - **Configure the clock**
         - Select your preferred time zone
       - **Partition disks**
         - Choose "Guided - Use entire disk"
         - Select SCSI disk listed (disk size should roughly match that set during VM creation)
         - Select "All files in one partition"
         - Select "Finish partitioning"
         - You will need to explicitly confirm "yes" to write changes to disk
       - **Configure package manager**
         - Select defaults and your geographic location for optimal mirror selection
       - **Software Selection**
         - Uncheck "Debian Desktop Environment" options for efficient, headless server
         - Check "SSH server"
         - Check "standard system utilities"
    - When prompted, reboot the VM to complete installation.

4. **Configure VM**
    - In the Proxmox web UI, navigate to the *Console* tab and log in with your non-elevated user
    - Confirm WAN connectivity by pinging a Google DNS server:
      ```bash
      ping 8.8.8.8
      ```
    - Elevate to root:
      ```bash
      su -
      ```
    - Add the non-elevated user to the `sudo` group:
      ```bash
      usermod -aG sudo [NON_ELEV_USER]
      ```
    - Update packages and install common productivity tools:
      ```bash
      apt update && apt upgrade && apt install -y sudo tmux vim btop tree
      ```
    - Install the QEMU guest agent:
        ```bash
        apt install -y qemu-guest-agent
        ```
    - In the Proxmox web UI, navigate to the *Options* tab
    - Make sure that **QEMU Guest Agent** is set to **Enabled**
    - Reboot the VM. If the guest agent is running properly, you should see the VM's IP listed on the *Summary* tab.
    - Log back in with your non-elevated user and confirm that `sudo` is working. The following command should return `root`:
        ```bash
        sudo whoami
        ```

4. **Snapshot**
    - Once you confirm that your non-elevated user has `sudo` access, power down the VM.
    - On the *Snapshots* tab, take a snapshot to serve as your base rollback point.

## Resources

- [Debian Official ISO Downloads](https://www.debian.org/distrib/)
- [Proxmox Recommended Disk and NIC Settings](https://pve.proxmox.com/wiki/Performance_Tweaks)
- [Debian Installation Guide](https://www.debian.org/releases/bookworm/amd64/index.en.html)

