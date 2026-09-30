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
