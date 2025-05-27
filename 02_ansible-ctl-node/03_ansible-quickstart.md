# Ansible Quickstart

## Goal

Validate that Ansible is installed and capable of running a basic local playbook.

## Requirements

- Ansible is installed on the control node
- No additional nodes required for this test

## Procedure

1. Create and move to a new working directory:
    ```bash
    mkdir ~/quickstart && cd ~/quickstart
    ```

1. Create a basic host inventory file with the following content:
    ```bash
    vim hosts
    ```
    ```ini
    [local]
    localhost ansible_connection=local
    ```

2. Create a test playbook with the following content:
    ```bash
    vim test.yml
    ```
    ```yaml
    ---
    - name: Test Ansible Set-up
      hosts: local
      tasks:
        - name: Print a confirmation message
          debug:
            msg: "Ansible is working correctly on the control node."
    ```

3. Run the playbook:

    ```bash
    ansible-playbook -i hosts test.yml
    ```

4. Confirm that output includes the expected debug message.

## Resources

- [Getting Started with Ansible](https://docs.ansible.com/ansible/latest/getting_started/index.html)
- [Ansible Inventory File Basics](https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html)
- [Ansible Debug Module](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/debug_module.html)
- [Ansible Playbook CLI Reference](https://docs.ansible.com/ansible/latest/cli/ansible-playbook.html)

