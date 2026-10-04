# Ansible Playbooks

This directory contains Ansible playbooks and configurations for setting up and managing services in the homelab.

## Directory Structure

-   `inventory/`: Contains your inventory files. Copy `hosts.example.yml` to `hosts.yml` here to define your servers.
-   `roles/`: Contains reusable Ansible roles.
-   `group_vars/`: Contains variables that can be used across playbooks.
-   `requirements.yml`: Collections, pinned exactly.
-   `requirements-tools.txt`: `ansible-core`, `ansible-lint` and `yamllint`, pinned exactly. CI installs the same versions.

## Prerequisites

- Configure an [Ansible control node](https://github.com/JeannieFallon/homelab-net/tree/main/02_ansible-ctl-node).
- Every target VM must meet the contract in [ADR 0003](../docs/adr/0003-roles-configure-existing-vms.md): Debian 13,
  reachable over SSH as `ansible` with key-only login, and passwordless sudo. VMs cloned from the cloud-init template
  meet it out of the box, with the control node's public key already installed.
- Install the pinned collections:

```bash
ansible-galaxy collection install -r requirements.yml
```

- Copy `inventory/hosts.example.yml` to `inventory/hosts.yml` (gitignored) and define your servers. Example:

```yaml
all:
  vars:
    ansible_user: ansible
  children:
    workloads:
      hosts:
        dev-01:
          ansible_host: 192.0.2.30
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
Host dev-01
    HostName 192.0.2.30
    User ansible

# Keep defaults at end of config to allow for overriding
Host *
    IdentityFile ~/.ssh/id_ed25519
    # Accept a new host's key on first contact, and refuse a known host whose key changed
    StrictHostKeyChecking accept-new
    ControlMaster auto
    ControlPath ~/.ssh/ansible-%r@%h:%p
    ControlPersist 60s
```

Ansible honors this setting: `ansible.cfg` no longer sets `host_key_checking = False`, so a VM answering with an
unexpected key at a known address is refused instead of configured.

### Rebuilt VMs

A VM that is deliberately rebuilt (for example, re-cloned from the template at the same address) has a new host key,
and SSH refuses it. After confirming the rebuild was intended, remove the old key so the next connection accepts the
new one:

```bash
ssh-keygen -R dev-01
ssh-keygen -R 192.0.2.30
```

## Running Playbooks

Test connectivity with the hosts in your inventory:

```bash
ansible [HOSTS_GROUP] -m ping
```

Lint and syntax check, the same checks CI runs (lint from the repo root):

```bash
yamllint --strict .
ansible-lint
ansible-playbook --syntax-check site.yml
```

Run playbook (default config points to `inventory/hosts.yml`). The `ansible` account has passwordless sudo, so no
password prompt is needed:

```bash
ansible-playbook site.yml
```

## Utility

To efficiently sync content in this directory from another machine to the headless Ansible control node, use rsync:
```bash
rsync -avz --delete ./ [SSH_ALIAS]:~/playbooks/
```
