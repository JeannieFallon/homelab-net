# common

Baseline for every host: Debian 13 check, baseline packages and the QEMU guest agent, the personal admin account,
key-only SSH, and a default-deny firewall that allows SSH only from `lan_cidrs`.

Applied to `all` in `site.yml`. Package upgrades are not part of this role; run `upgrade.yml` for those.

## Requirements

The host meets the contract in [ADR 0003](../../../docs/adr/0003-roles-configure-existing-vms.md): Debian 13,
reachable over SSH as `ansible` with key-only login and passwordless sudo.

## Variables

Set in the inventory (`inventory/hosts.yml`). The role has no defaults for these and fails early if they're missing:

| Variable | Purpose |
| --- | --- |
| `lan_cidrs` | List of subnets allowed to reach SSH (and Grafana, in the `grafana` role). Must include the workstation's and the control node's subnets. |
| `admin_user` | Name of the personal admin account. |
| `admin_ssh_pubkey` | The workstation's public key, authorized for the personal admin. |

Set in the vault (`group_vars/all/vault.yml`, gitignored; see `vault.yml.example`):

| Variable | Purpose |
| --- | --- |
| `vault_admin_password_hash` | SHA-512 or yescrypt hash of the personal admin's sudo password. |

Role defaults (`defaults/main.yml`): `common_packages`, `common_sshd_dropin`, `common_apt_cache_valid_time`.

`lan_cidrs` has no default, although a documentation range would satisfy the syntax, because a placeholder value would
lock SSH out the moment ufw is enabled.

## Deviations from the walkthrough

Compared with [`create_vm.md`](../../../docs/walkthroughs/create_vm.md), the firewall steps in
[`01_node-metrics.md`](../../../03_net-monit-stack/manual/01_node-metrics.md), and the earlier version of this role:

- **Debian 13, not 12.** The role asserts Debian 13 and stops on anything else
  ([ADR 0004](../../../docs/adr/0004-debian-13-base.md)).
- **Accounts.** The walkthrough installed Debian interactively and added the installer's user to `sudo`. VMs now come
  from a cloud-init template that creates only the `ansible` account
  ([ADR 0003](../../../docs/adr/0003-roles-configure-existing-vms.md)). This role creates the personal admin, with key
  login and password sudo, from a hash kept in the vault ([ADR 0006](../../../docs/adr/0006-access-and-secrets.md)).
- **SSH password login is off.** The walkthrough left it on. A drop-in in `/etc/ssh/sshd_config.d/` sets
  `PasswordAuthentication no` and `KbdInteractiveAuthentication no`, is checked with `sshd -t` before it's written, and
  reloads `ssh.service`.
- **SSH is allowed only from `lan_cidrs`.** The walkthrough ran `ufw allow OpenSSH`, which allows SSH from anywhere.
  The earlier role also allowed all traffic from the management network, which made every per-port rule meaningless;
  that rule is gone.
- **No upgrades.** The walkthrough and the earlier role ran a full upgrade. Upgrades now live in `upgrade.yml`, and this
  role refreshes the apt cache only when it's more than an hour old.
- **Node exporter moved** to its own `node_exporter` role.
- The role does not remove rules left on manually built VMs. It's written for fresh clones of the template.

## Verification status

Linted with `ansible-lint` (production profile). **Not yet run on hardware.** To confirm on a test clone:

- sshd keeps the first value it reads for each keyword (sshd_config(5), docs), and Debian's `sshd_config` includes
  `sshd_config.d/*.conf` before its own settings (from memory), so `10-homelab.conf` overrides cloud-init's
  `50-cloud-init.conf`.
- `sshd -t -f` accepts the drop-in on its own as a complete config file (from memory).
- The cloud image doesn't include `qemu-guest-agent` (from memory).
- Debian 13's OpenSSH runs as `ssh.service` rather than through socket activation (from memory).
