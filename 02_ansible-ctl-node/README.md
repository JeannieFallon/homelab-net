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

