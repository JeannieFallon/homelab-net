# Network Monitoring Stack: Automated Deployment

This directory contains the Ansible-based workflow for deploying the full network monitoring stack.

## Goal

Automate the provisioning and configuration of observability tools using a centralized Ansible control node.

## How It Works

The playbooks and roles used in this deployment live in the shared [`homelab-net/ansible/`](../../ansible/) directory.
This runbook provides high-level guidance on how to execute them and what order to follow.

## Prerequisites

- Ansible is installed and configured on your control node
- SSH access to all target nodes (VMs or containers)
- An up-to-date inventory file pointing to those targets
- Verified manual installation steps (recommended before automation)

## Files

- [`ansible-runbook.md`](ansible-runbook.md) – Step-by-step guide to running the full stack via Ansible

## Notes

- You are encouraged to complete the `manual/` procedure first to build understanding and confidence before automating.
- This directory assumes some familiarity with Ansible and Linux systems administration.
