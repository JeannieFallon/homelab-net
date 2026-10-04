#!/usr/bin/env bash
# Turn a fresh clone of the Debian 13 cloud-init template into the control
# node. Run as the `ansible` user from a copy of this repo on the clone.
# Safe to rerun.
#
# Any arguments are passed to ansible-playbook, for example:
#   scripts/bootstrap-control.sh --ask-vault-pass
set -euo pipefail

if [[ ${EUID} -eq 0 ]]; then
    echo "Run as the ansible user, not root." >&2
    exit 1
fi

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
playbooks="${repo_root}/playbooks"

echo "==> Installing pipx and git"
missing=()
for pkg in pipx git; do
    if ! dpkg-query -W -f='${Status}' "${pkg}" 2>/dev/null | grep -q 'install ok installed'; then
        missing+=("${pkg}")
    fi
done
if ((${#missing[@]})); then
    sudo apt-get update
    sudo apt-get install -y "${missing[@]}"
fi

# pipx puts its apps here; a fresh login shell may not have it on PATH yet.
export PATH="${HOME}/.local/bin:${PATH}"

echo "==> Installing the pinned Ansible tools"
"${repo_root}/scripts/install-tools.sh"

echo "==> Installing the pinned collections"
ansible-galaxy collection install -r "${playbooks}/requirements.yml"

echo "==> Running the control play"
cd "${playbooks}"
ansible-playbook site.yml --limit control "$@"
