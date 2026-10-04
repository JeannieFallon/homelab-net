#!/usr/bin/env bash
# Run site.yml twice and fail unless every host in the second run's recap
# shows changed=0, failed=0 and unreachable=0. Run on the control node.
#
# Any arguments are passed to both runs, for example:
#   scripts/converge-check.sh --vault-password-file ~/.vault_pass
set -euo pipefail

playbooks="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/playbooks"
log="$(mktemp)"
trap 'rm -f "${log}"' EXIT

cd "${playbooks}"

echo "==> First run"
ansible-playbook site.yml "$@"

echo "==> Second run"
ansible-playbook site.yml "$@" | tee "${log}"

# Host lines in the recap look like:
#   mon-01 : ok=42 changed=0 unreachable=0 failed=0 skipped=3 rescued=0 ignored=0
recap="$(sed 's/\x1b\[[0-9;]*m//g' "${log}" | awk '/^PLAY RECAP/ {r = 1; next} r && /changed=/')"

if [[ -z ${recap} ]]; then
    echo "FAIL: no PLAY RECAP found in the second run" >&2
    exit 1
fi

dirty="$(awk '{
    for (i = 2; i <= NF; i++) {
        split($i, kv, "=")
        if ((kv[1] == "changed" || kv[1] == "failed" || kv[1] == "unreachable") && kv[2] != 0) {
            print "  " $0
            next
        }
    }
}' <<<"${recap}")"

if [[ -n ${dirty} ]]; then
    echo "FAIL: the second run was not clean:" >&2
    echo "${dirty}" >&2
    exit 1
fi

echo "PASS: the second run reported changed=0 on every host"
