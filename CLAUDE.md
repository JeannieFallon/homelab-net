## Project

Infrastructure-as-code for a home network and endpoint monitoring stack,
built specification-first. Manual procedures are captured as markdown
walkthroughs, then converted into Ansible roles that reproduce them.

This repo is also a public portfolio piece demonstrating Linux platform
engineering. Treat quality as a requirement: accurate procedures,
idempotent roles, clean structure, and writing that holds up to review
by an experienced engineer.

Constraints:
- Public repo. Never commit real hostnames, IPs, credentials, or topology.
  Real inventory stays gitignored; commit placeholder examples only.
- Procedures were written for Debian 12 around 2024. Treat version-specific
  steps as possibly stale and flag them rather than assuming they're correct.
- Fact-checking against docs is useful. It is not the same as verifying on
  hardware. Say which one a claim rests on.

## Agent skills

### Issue tracker

Issues are tracked in GitHub Issues on JeannieFallon/homelab-net, via the `gh` CLI. See `docs/agents/issue-tracker.md`.

### Triage labels

Default vocabulary: `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: one `CONTEXT.md` and `docs/adr/` at the repo root. See `docs/agents/domain.md`.

## Git workflow

- One branch per spec. Name it `<issue-number>-<short-name>`.
- Tickets from that spec are worked on the same branch, one or more commits each.
- Open one PR per spec, as a draft, once the first ticket is done.
- PR body links the spec and closes each completed ticket: `Closes #<n>`.
- The human pushes. Stop and ask before any step that needs a push.
