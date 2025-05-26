# Install Ansible on Control Node

## Goal

Install Ansible on the control node using a method appropriate for a lightweight homelab VM.

## Requirements

- Debian VM is up and accessible via SSH
- System is connected to the internet

## Procedure

1. Update system packages:
    ```bash
    sudo apt update && sudo apt full-upgrade
    ```

2. Option A: Install via apt (stable)
    ```bash
    sudo apt install -y ansible
    ```

3. Option B: Install via pip (latest)
    ```bash
    sudo apt install -y python3-pip
    pip3 install --user ansible
    ```

4. Confirm Ansible is installed:
    ```bash
    ansible --version
    ```

## Resources

- [Ansible Installation Guide (Official)](https://docs.ansible.com/ansible/latest/installation_guide/index.html)
- [Ansible on Debian (Debian Wiki)](https://wiki.debian.org/ansible)
- [Using pip for User Installs](https://pip.pypa.io/en/stable/user_guide/#user-installs)

