# Ansible connects as a passwordless service account; the admin keeps password sudo

Ansible connects to every VM as a dedicated `ansible` account created by cloud-init, with key-only login and passwordless sudo. The operator's personal admin account is created by `common`, with key login and password sudo. SSH password login is turned off on every VM through a validated sshd drop-in. Secrets (the personal admin's password hash and the Grafana admin password) live in Ansible Vault files that are gitignored. Each has a committed `vault.yml.example` listing the variables it needs, named with a `vault_` prefix.

Passwordless sudo for `ansible` is what lets `site.yml` and the converge check run back to back without `-K`. It also makes the `ansible` key the most valuable credential in the lab, so it is limited to the control node and the workstation. Interactive work goes through the personal account, which still asks for a password before sudo. Host keys are accepted on first contact (`StrictHostKeyChecking accept-new`) and checked after that, replacing the old `host_key_checking = False`, so a VM answering at the wrong IP is refused instead of configured.

Committing encrypted vault files was the alternative. We keep them out of the repo because it is public, and a committed ciphertext is only as safe as the vault password for as long as the repo exists.
