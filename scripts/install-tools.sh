#!/usr/bin/env bash
# Install the Ansible tools pinned in playbooks/requirements-tools.txt with
# pipx, one virtualenv per tool. Used by bootstrap-control.sh and by CI, so
# both get the same versions installed the same way. Safe to rerun: a tool
# already at its pinned version is left alone.
set -euo pipefail

tools_file="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/playbooks/requirements-tools.txt"

# Apply the same pins to dependencies, so the ansible-core inside
# ansible-lint's virtualenv matches the one that runs the playbooks.
export PIP_CONSTRAINT="${tools_file}"

installed="$(pipx list --short 2>/dev/null || true)"

grep -Ev '^[[:space:]]*(#|$)' "${tools_file}" | while read -r spec; do
    name="${spec%%==*}"
    version="${spec#*==}"
    if grep -qx "${name} ${version}" <<<"${installed}"; then
        echo "${name} ${version} already installed"
    else
        pipx install --force "${spec}"
    fi
done
