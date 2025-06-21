# Install Ansible on Control Node

## Goal

Install the latest stable version of Ansible system-wide on the `ansible-ctl` node using the Ubuntu PPA, as recommended
by the official Ansible documentation. This node will serve as the Ansible control node used to run playbooks to
automate system configuration of other managed nodes.

## Requirements

- Debian 12 (Bookworm) installed
- Non-elevated user with `sudo` privileges
- WAN access

## Procedure

1. Log into the `ansible-ctl` node as your non-elevated user.

2. Set the Ubuntu codename for compatibility (Debian 12 is compatible with `jammy`):

    ```bash
    UBUNTU_CODENAME=jammy
    ```

3. Add the Ansible GPG key:

    ```bash
    wget -O- "https://keyserver.ubuntu.com/pks/lookup?fingerprint=on&op=get&search=0x6125E2A8C77F2818FB7BD15B93C4A3FD7BB9C367" | sudo gpg --dearmour -o /usr/share/keyrings/ansible-archive-keyring.gpg
    ```

4. Add the Ansible PPA to your sources list:

    ```bash
    echo "deb [signed-by=/usr/share/keyrings/ansible-archive-keyring.gpg] http://ppa.launchpad.net/ansible/ansible/ubuntu $UBUNTU_CODENAME main" | sudo tee /etc/apt/sources.list.d/ansible.list
    ```

5. Update package index:

    ```bash
    sudo apt update
    ```

6. Install Ansible:

    ```bash
    sudo apt install -y ansible
    ```

7. You should now see the latest stable version of Ansible, installed system-wide.

    ```bash
     dpkg -l | grep ansible
    ```

## Resources

- [Ansible Installation Guide (Official)](https://docs.ansible.com/ansible/latest/installation_guide/index.html)
- [Installing Ansible on Debian](https://docs.ansible.com/ansible/latest/installation_guide/installation_distros.html#installing-ansible-on-debian)
- [Ansible PPA](https://launchpad.net/~ansible/+archive/ubuntu/ansible)
