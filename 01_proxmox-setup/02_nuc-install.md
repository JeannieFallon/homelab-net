# Install Proxmox on Intel NUC

## Goal
Boot the Intel NUC from the prepared USB installer, configure BIOS settings if needed, and install Proxmox VE onto the
internal drive.

## Requirements
- Intel NUC with peripherals connected:
  - Monitor (HDMI or Mini DisplayPort)
  - USB keyboard and mouse
  - Ethernet cable plugged into local network
- USB-A flash drive containing the Proxmox ISO (created in [01_proxmox-iso.md](01_proxmox-iso.md))
- BIOS access key (usually `F2` or `Del`)
- Power source

## Procedure

1. **Insert USB and Power On**
   - Plug the USB installer into a USB-A port on the NUC
   - Power on the NUC
   - As soon as NUC powers on, start tapping `F2` to launch the Intel Visual BIOS menu

2. **BIOS Set-up**
   - On the BIOS main page, confirm the following:
     - Enable **UEFI boot**
     - Set **USB device** as primary boot device

  <p align="center">
      <img src="../res/screenshots/02_nuc-install_00.png" alt="UEFI Boot" width="50%">
  </p>
     
  - In *Advanced > Security > Security Features*:
     - Enable **Virtualization Technology**
  - In *Advanced > Boot > Secure Boot*:
     - Disable **Secure Boot**
       - **Note**: The Proxmox ISO is not signed by a trusted certificate authority, so secure Boot may cause
         installer failures or silent boot hangs
   - Save and exit

  <p align="center">
      <img src="../res/screenshots/02_nuc-install_01.png" alt="Save" width="50%">
  </p>

3. **Boot to Proxmox Installer**
   - You should see the Proxmox boot screen
   - Choose `Install Proxmox VE` from the menu

4. **Run the Installer**
   - Accept the license agreement
   - Select the internal drive as the target for installation
   - Set:
     - Country/timezone
     - Admin password
     - FQDN (e.g., `proxmox.local`)

5. **Network Configuration**
   - If possible, assign a **static IP address**
       - **Note**: A DHCP-assigned address from your home router will work for initial set-up
   - Confirm network interface (e.g., `enp1s0`)
   - Use your gateway and DNS (typically your router’s IP)

6. **Complete Installation**
   - Wait for installation to complete
   - Remove the USB drive when prompted
   - Reboot into the installed system
       - **Note**: If you don't remove the USB drive, the NUC will boot back into the installer. Power off the NUC,
         remove the drive, and then power the device back on.

7. **Confirm System Boot**
   - You should see a console message showing the Proxmox host IP and access instructions:
     ```
     You can now connect to the Proxmox VE web interface:
     https://[PXMX_IP_ADDR]:8006
     ```

## Resources
- [Proxmox Installation Guide](https://pve.proxmox.com/wiki/Installation)
- [BIOS Settings Glossary for Intel NUC](https://www.intel.com/content/www/us/en/support/articles/000006028/intel-nuc.html)

