# Install Linux on a Laptop

## Goal

Install Linux on an laptop. For the example below, we'll install Debian 13 on a Windows laptop.

## Requirements

- Laptop with no critical data or usage
    - **WARNING**: transfer off any needed data BEFORE you begin
- Check online to make sure your laptop specs (CPU, graphics card, etc.) are known to run Linux without issue
- USB stick with minimum 8GB
    - **WARNING**: all data will be erase

## Procedure

1. **Update existing OS and firmware**
    - If the laptop has an OS currently installed, perform all system updates before wiping. This ensures the BIOS/firmware gets the latest version, since vendor firmware updaters are typically Windows-only
    - On Windows: `Settings → Windows Update → Check for updates`, install all, reboot, repeat until no more updates appear
    - Also run any vendor-specific updater (e.g., Samsung Update, Lenovo Vantage, Dell Command Update) — these surface firmware/driver updates not delivered via Windows Update

2. **Verify BIOS is up to date**
    - For most modern consumer laptops, BIOS updates are delivered via the vendor's Windows updater, not from inside the BIOS menu itself
    - Check current BIOS version on Windows: `Win + R` → `msinfo32` → note "BIOS Version/Date"
    - Compare against the latest version on the vendor's support site for your model
    - If outdated, install via the vendor updater and reboot

3. **Download the Debian ISO**
    - Go to: https://www.debian.org/CD/live/
    - Download the **GNOME live ISO** for amd64: `debian-live-13.*.*-amd64-gnome.iso` (~3.5 GB)
        - Live image lets you boot into a working Debian environment from USB and test hardware compatibility before committing to install
        - GNOME is Debian's default desktop, but subsitute an ISO with KDE/Xfce/etc. if preferred

4. **(Recommended) Verify ISO checksum**
    - Download `SHA256SUMS` from the same directory as the ISO
    - In PowerShell, run:
      ```powershell
      Get-FileHash debian-live-13.x.x-amd64-gnome.iso -Algorithm SHA256
      ```
    - Compare the output against the matching line in `SHA256SUMS`. They should be identical
    - This confirms the ISO downloaded without corruption and wasn't tampered with

5. **Flash the ISO to a USB stick**
    - Download [Rufus](https://rufus.ie/) (free Windows tool for writing bootable USBs)
    - Plug in the USB stick
    - Open Rufus → select the USB device → select the downloaded Debian ISO → leave defaults → click `Start`
        - If prompted to download files for compatibility with syslinux, select `Yes`
    - When prompted, choose "Write in ISO Image mode (recommended)"
    - Wait 5–15 minutes depending on USB speed
    - Note: you cannot simply copy the ISO file to the USB stick. It must be written as a bootable disk image, which Rufus handles

6. **Configure BIOS for USB boot**
    - Reboot the laptop and press the BIOS key (probably `F2` or `F10`) at the vendor logo 
    - Disable Secure Boot (typically under `Boot` or `Security` menu). Debian 13 supports Secure Boot, but disabling avoids edge-case issues during install
    - Either move USB to the top of the boot priority list, or note the one-time boot menu key
    - Save and exit

7. **Live boot test (non-destructive)**
    - With the USB plugged in, reboot
    - At the vendor logo, press the boot menu key and select the USB device (or let it auto-boot if you set priority)
    - From the Debian boot menu, choose `Live system (amd64)`
    - Once at the GNOME desktop, verify:
        - Wi-Fi connects
        - Keyboard and trackpad work
        - Display, brightness keys, and any critical hardware function
    - This step does not modify the internal drive. You can reboot back into the existing OS at any time

8. **Install Debian**
    - From within the live session, double-click the `Install Debian` icon on the desktop or taskbar
        - Note: you'll need to be plugged into power
    - Step through prompts: language, location, keyboard layout, hostname, user account, password
    - At the partitioning step, choose `Guided — use entire disk` to wipe the existing OS and use the full drive for Debian. **This is the destructive step.** Confirm only when ready
    - Wait 15–30 minutes for install to complete
    - Remove the USB when prompted and reboot
    - Once you've confirmed successful reboot, you'll need to confirm that boot priority is correct
        - Shut down fully
        - Unplug USB stick
        - Start up and enter BIOS menu
        - Confirm that Debian is top boot priority
        - Continue system boot

9. **Post-install setup**
    - On first login, open a terminal and run:
      ```bash
      sudo apt update && sudo apt full-upgrade
      ```
    - **Note**: if `apt` fails, check if system clock is correct. If not, perform the following to get NTP to sync:
        - Check status: `timedatectl`
        - Expected output: `System clock synchronized: yes` and `NTP service: active`
        - If `NTP service: inactive` or `not supported`, install and enable `systemd-timesyncd`:
          ```bash
          sudo apt install systemd-timesyncd
          sudo systemctl enable --now systemd-timesyncd
          ```
        - If `apt` itself won't run because of the clock skew (chicken-and-egg), set the time manually first using a known-correct source (phone, another computer):
          ```bash
          sudo date -s "YYYY-MM-DD HH:MM:SS"
          ```
          Then proceed with `apt install systemd-timesyncd` as above
    - Install non-free firmware if any hardware misbehaves (Wi-Fi, GPU, etc.):
      ```bash
      sudo apt install firmware-linux firmware-iwlwifi
      ```
    - Apply any hardware-specific tweaks (see separate notes for your laptop model)
    - Configure SSH, dotfiles, and tooling per your preference

## Notes

- **Hardware-specific quirks** (keyboard backlight, OLED brightness, fingerprint reader, etc.) vary by laptop model. Search `[your laptop model] linux` before committing to identify known issues
- **The live boot in step 7 is the most important non-destructive checkpoint.** If Wi-Fi or keyboard don't work in the live environment, they won't work after install either





## Resources

- [Debian Official ISO Downloads](https://www.debian.org/distrib/)
- [Debian Installation Guide](https://www.debian.org/releases/bookworm/amd64/index.en.html)

