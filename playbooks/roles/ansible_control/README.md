# ansible_control

Keeps the control node's Ansible toolchain in line with the repo's pins: the tools in `requirements-tools.txt`
(installed with pipx, one virtualenv per tool), the collections in `requirements.yml`, and git. Creates the control
node's ed25519 key pair if it's missing.

Applied to `control` in `site.yml`. The control node also gets `common` and `node_exporter`, like every other host.

## Requirements

- The control node is in the inventory with `ansible_connection: local`. The role reads the pin files from the repo
  checkout through `playbook_dir`, which only points at the right files when the play runs on the control node itself.
- The control node was bootstrapped with `scripts/bootstrap-control.sh`. Until then there's no Ansible on it to run
  this role.

## Building the control node

The full order, from an empty Proxmox host:

1. **Build the template.** Follow the
   [Debian 13 cloud-init template walkthrough](../../../docs/walkthroughs/cloud-init-template.md). At this point the
   template's cloud-init SSH keys hold only the workstation's public key.
2. **Clone the control node** from the template, as in the walkthrough's per-clone checklist.
3. **Copy the repo to the clone** from the workstation. git isn't on the clone yet, so use rsync, and include the
   gitignored files the run needs (`playbooks/inventory/hosts.yml` and `playbooks/group_vars/*/vault.yml`):

   ```bash
   rsync -avz ./ ansible@<control-node>:~/homelab-net/
   ```

4. **Bootstrap.** On the clone, as `ansible`:

   ```bash
   ~/homelab-net/scripts/bootstrap-control.sh --ask-vault-pass
   ```

   The script installs pipx and git, installs the pinned tools and collections, and runs
   `site.yml --limit control`. That run applies this role, which creates `~/.ssh/id_ed25519`. The script is safe to
   rerun.

5. **Add the control node's key to the template.** Append the contents of `~/.ssh/id_ed25519.pub` on the control node
   to the template's cloud-init SSH keys, keeping the workstation's key. The walkthrough has the step.
6. **Clone the other VMs** (monitoring server, workload VMs) from the updated template, add them to the inventory, and
   run `site.yml` from the control node.

VMs cloned before step 5 don't have the control node's key. Re-clone them, or add the key to `ansible`'s
`authorized_keys` by hand.

## Variables

All in `defaults/main.yml`:

| Variable | Default | Purpose |
| --- | --- | --- |
| `ansible_control_tools_file` | `{{ playbook_dir }}/requirements-tools.txt` | Tool pins, one `name==version` per line |
| `ansible_control_collections_file` | `{{ playbook_dir }}/requirements.yml` | Collection pins |
| `ansible_control_tools` | parsed from the tools file | List of tool specs to install |
| `ansible_control_ssh_key` | `~/.ssh/id_ed25519` | Private key path for the control node's key pair |

## Changing a pin

Edit `requirements-tools.txt` or `requirements.yml`, then run `site.yml --limit control`. CI reads the same files, so a
pin change is tested on the PR that makes it.

Tools are installed with `PIP_CONSTRAINT` pointing at the pin file, so the `ansible-core` inside `ansible-lint`'s
virtualenv matches the pinned one. That constraint only applies when a tool is (re)installed: after bumping
`ansible-core` alone, run `pipx reinstall ansible-lint` with the same `PIP_CONSTRAINT` to bring `ansible-lint`'s copy in
line.

## Deviations from the walkthrough

Compared with [`02_install-ansible.md`](../../../02_ansible-ctl-node/02_install-ansible.md) and
[`01_create-debian-vm.md`](../../../02_ansible-ctl-node/01_create-debian-vm.md):

- **pipx instead of the Ubuntu PPA.** The walkthrough added the Ansible PPA under the `jammy` codename and installed
  the `ansible` package system-wide. Mixing an Ubuntu PPA into Debian is fragile, and the package tracked whatever the
  PPA published. The role installs `ansible-core`, `ansible-lint` and `yamllint` with pipx at the versions pinned in
  `requirements-tools.txt`, which CI also reads.
- **`ansible-core` plus pinned collections, not the `ansible` bundle.** The bundle ships dozens of collections at
  whatever versions it was built with. The repo needs two, pinned in `requirements.yml`.
- **The control node is a template clone, bootstrapped by a script.** The walkthrough installed Debian interactively.
  The control node is now built like every other VM
  ([ADR 0003](../../../docs/adr/0003-roles-configure-existing-vms.md)), so rebuilding it is no harder than rebuilding
  any other VM.
- **The control node manages itself.** After the bootstrap it gets the same baseline, node exporter, and firewall as
  every other host.
- **Debian 13, not 12** ([ADR 0004](../../../docs/adr/0004-debian-13-base.md)).

## Verification status

Linted with `ansible-lint` (production profile). The parsing and skip logic of `scripts/install-tools.sh` was checked
against a stub `pipx`. **Not yet run on hardware.** To confirm on a fresh clone:

- `apt install pipx` on Debian 13 pulls in `python3-venv`, which pipx needs to create virtualenvs (from memory).
- `community.general.pipx` finds the Debian pipx through `/usr/bin/python3 -m pipx`, and `community.general.ansible_galaxy_install`
  finds `ansible-galaxy` on the `PATH` of the user running Ansible.
- A second run of `bootstrap-control.sh` and of `site.yml --limit control` reports no changes.
