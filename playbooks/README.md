# Ansible Playbooks

This directory contains Ansible playbooks and configurations for setting up and managing services in the homelab.

## Directory Structure

-   `inventory/`: Contains your inventory files. You should create a `hosts` file here to define your servers.
-   `playbooks/`: Contains the Ansible playbooks.
-   `roles/`: Contains reusable Ansible roles.
-   `group_vars/`: Contains variables that can be used across playbooks.

## Prerequisites

- Configure an [Ansible control node](https://github.com/JeannieFallon/homelab-net/tree/main/02_ansible-ctl-node).
- Update the inventory hosts file at `inventory/hosts` and define your servers. Example:

```ini
[dev]
dev-vm ansible_host=192.168.1.100 ansible_user=dev-user
```

- If needed, generate SSH keys on the Ansible control node. For use on a dedicated
Ansible control node, a default key is acceptable. For use on a multi-purpose
node, consider creating a bespoke key for Ansible use only (must update Ansible
config to use bespoke key):

```bash
ssh-keygen -t ed25519
```

- Update SSH config with alias for your server. Example using server defined above:

```config
Host dev-vm
    HostName 192.168.1.100
    User dev-user

# Keep defaults at end of config to allow for overriding
Host *
    IdentityFile ~/.ssh/id_ed25519
    ControlMaster auto
    ControlPath ~/.ssh/ansible-%r@%h:%p
    ControlPersist 60s
```

- Copy your SSH key to the server for passwordless auth, using the new SSH alias:

```bash
ssh-copy-id dev-vm
```

## Running Playbooks

Test connectivity with the hosts in your inventory. Enter the user's password when prompted:

```bash
ansible [HOSTS_GROUP] -m ping
```

Syntax check with linter. **Note**: future work will add `ansible-lint` to the Ansible control node set-up:

```bash
ansible-playbook site.yml --syntax-check
```

Run playbook (default config points to hosts file). **NOTE**: this command
requires manually entering the target VM user's sudo password, as prompted by
the `-K` flag. Future work will add a dedicated Ansible service accounts to
target VMs with no password, an SSH key, and limited or specific sudo rights:

```bash
ansible-playbook site.yml -K
```

## Utility

To efficiently sync content in this directory from another machine to the headless Ansible control node, use rsync:
```bash
rsync -avz --delete ./ [SSH_ALIAS]:~/playbooks/
```