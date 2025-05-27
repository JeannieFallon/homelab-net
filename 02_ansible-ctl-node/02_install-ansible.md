# Install Ansible on Control Node

## Goal

Install the latest stable version of Ansible system-wide on the `ansible-ctl` node using Debian's official backports
repository. This node will serve as the Ansible control node used to run playbooks to automate system configuration of
other managed nodes.

## Requirements

- Debian 12 (Bookworm) installed
- Non-elevated user with `sudo` privileges
- WAN access

## Procedure

1. Log into the `ansible-ctl` node as your non-elevated user.

2. Create a new entry in APT sources for backports:
    ```bash
    echo 'deb http://deb.debian.org/debian bookworm-backports main' | sudo tee /etc/apt/sources.list.d/backports.list
    ```

2. Update package index:
    ```bash
    sudo apt update
    ```

5. Install Ansible from backports:
    ```bash
    sudo apt -t bookworm-backports install -y ansible
    ```

5. Verify installation:
    ```bash
    ansible --version
    ```

6. You should see the latest stable version of Ansible, now available system-wide.


## Resources

- [Ansible Installation Guide (Official)](https://docs.ansible.com/ansible/latest/installation_guide/index.html)
- [Installing Ansible on Debian](https://docs.ansible.com/ansible/latest/installation_guide/installation_distros.html#installing-ansible-on-debian)

