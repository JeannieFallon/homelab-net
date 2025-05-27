# Ansible Control Node

## Goal

Provision a dedicated VM to serve as the Ansible control node. This machine will be used to automate the setup and
configuration of other components in the homelab network stack.

## Requirements

- Proxmox VE already installed and accessible
- Debian ISO (minimal installation recommended)
- SSH access from your primary workstation (e.g., MacBook)
- Internet access from the VM for package installation

## Procedure

This procedure is divided into three stages:

1. [**Create and Install Debian VM**](01_create-debian-vm.md)  
   - In the Proxmox web UI, create a new virtual machine and install Debian

2. [**Install Ansible**](02_install-ansible.md)  
   - Install Ansible and confirm basic functionality 

3. [**Run Ansible Quickstart**](03_ansible-quickstart.md)  
   - Test SSH access from your primary machine to the control node  
   - Set up a basic Ansible working directory and inventory
   - Run a test `ping` playbook to verify connectivity and Ansible functionality

## Resources

- [Ansible Documentation](https://docs.ansible.com/)
- [Ansible Installation Guide](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
- [Debian Cloud Images](https://cloud.debian.org/images/cloud/)
- [Proxmox: Create VM from ISO](https://pve.proxmox.com/wiki/VM_Templates_and_Cloning)
- [Ansible Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)
- [SSH Config Reference](https://man7.org/linux/man-pages/man5/ssh_config.5.html)

## Appendix A: Use of `sudo` and Root Privileges

This project follows the principle of least privilege when managing system access.

- **Root access is intentionally avoided** during normal operations.
- Administrative tasks are performed via `sudo` by users in the `sudo` group.
- Each elevated command is explicitly invoked with `sudo` in order to:
  - Maintain a clear audit trail (`/var/log/auth.log`)
  - Reduce risk of accidental system-wide changes
  - Preserve the working shell and user environment

The `root` account is reserved for recovery scenarios and is not used during automated configuration or everyday tasks.

If a new Debian VM does not have `sudo` installed, it should be added manually via:

```bash
su -
apt install sudo
usermod -aG sudo [NON_ELEVATED_USER]
```

This policy aligns with modern best practices and ensures predictable, secure behavior across all nodes in the lab.

## Appendix B: About Debian Backports

Debian backports are used to install Ansible on the control node.

**What are Backports?**  

Backports are newer versions of software packages that have been recompiled and tested to work on the current stable
release of Debian. They provide access to more up-to-date software without requiring a full upgrade to Debian testing or
unstable branches.

**Why Use Backports for Ansible?**  

Debian’s default repositories often lag behind upstream releases. Installing Ansible from backports ensures:
- Access to the latest stable Ansible features and bug fixes
- Official support and maintenance from the Debian project
- Seamless integration with APT (no need for pip, venvs, or third-party PPAs)

**How Backports Work**  
Backports packages are stored in a dedicated repository (e.g., `bookworm-backports` for Debian 12 Bookworm). They are **not installed by
default** to avoid accidental upgrades, but you can explicitly request them using:
```bash
sudo apt -t bookworm-backports install [PKG_NAME]
```

This gives you precise control over what gets upgraded, while maintaining system stability and compatibility.

