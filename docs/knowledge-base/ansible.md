# Ansible

## Description

Ansible is an open-source software provisioning, configuration management, and
application-deployment tool enabling infrastructure as code. It runs on many
Unix-like systems, and can configure both Unix-like systems as well as Microsoft
Windows. It includes its own declarative language to describe system
configuration. Ansible is agentless, temporarily connecting remotely via SSH or
Windows Remote Management (WinRM) to do its tasks.

## Installation

See the [Ansible control node set-up guide](../../02_ansible-ctl-node) for an installation walkthrough on a Linux server.

## Cheatsheet: Common CLI Commands

### Running Ad-hoc Commands

Ansible can be used to run commands on a set of hosts in parallel. The inventory file (`-i`) specifies the hosts.

-   **Ping all hosts:**
    ```bash
    ansible all -i inventory -m ping
    ```

-   **Run a shell command:**
    ```bash
    ansible webservers -i inventory -m shell -a 'df -h'
    ```

-   **Gather facts:**
    ```bash
    ansible all -i inventory -m setup
    ```

### Working with Playbooks

Playbooks are the core of Ansible, allowing you to define complex configurations and deployments.

-   **Run a playbook:**
    ```bash
    ansible-playbook -i inventory my_playbook.yml
    ```

-   **Run a playbook with extra variables:**
    ```bash
    ansible-playbook -i inventory my_playbook.yml --extra-vars "user=myuser"
    ```

-   **Check a playbook for syntax errors:**
    ```bash
    ansible-playbook --syntax-check my_playbook.yml
    ```

-   **Dry-run a playbook (see what would change):**
    ```bash
    ansible-playbook -i inventory my_playbook.yml --check
    ```

### Managing Roles with Ansible Galaxy

Ansible Galaxy is a public repository for Ansible roles.

-   **Install a role from Ansible Galaxy:**
    ```bash
    ansible-galaxy install geerlingguy.nginx
    ```

-   **Initialize a new role:**
    ```bash
    ansible-galaxy init my_new_role
    ```
