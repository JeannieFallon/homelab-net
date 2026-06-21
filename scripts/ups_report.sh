#!/usr/bin/env bash
#
# ups_report.sh — on-demand power/UPS event summary for Proxmox (pve)
#
# Reports: current uptime/load, boot history, recent power-relevant log
# events, login/reboot history, and a live NUT/UPS snapshot.
#
# Plain-text output by design (no ANSI color) so it stays clean when
# redirected to a file, piped to a pager, or pasted into a ticket.
#
# Usage:   ./ups_report.sh [-n UPS_NAME] [-d DAYS] [-h]
#   -n UPS_NAME   NUT device name as shown by `upsc -l`   (default: cyberpower)
#   -d DAYS       whole days of journal history to scan   (default: 7)
#   -h            show this help and exit
#
# Examples:
#   ./ups_report.sh
#   ./ups_report.sh -n cyberpower -d 3
#
# Exit codes: 0 always (this is a report, not a check). See `--check` note at bottom.

set -uo pipefail

UPS_NAME="cyberpower"
DAYS=7

usage() {
  cat <<'USAGEEOF'
ups_report.sh — on-demand power/UPS event summary for Proxmox (pve)

Usage:   ./ups_report.sh [-n UPS_NAME] [-d DAYS] [-h]
  -n UPS_NAME   NUT device name as shown by `upsc -l`   (default: cyberpower)
  -d DAYS       whole days of journal history to scan   (default: 7)
  -h            show this help and exit

Examples:
  ./ups_report.sh
  ./ups_report.sh -n cyberpower -d 3
USAGEEOF
}

while getopts ':n:d:h' opt; do
  case "$opt" in
    n) UPS_NAME="$OPTARG" ;;
    d) DAYS="$OPTARG" ;;
    h) usage; exit 0 ;;
    :) printf 'Error: -%s requires an argument.\n\n' "$OPTARG" >&2; usage >&2; exit 2 ;;
    \?) printf 'Error: unknown option -%s\n\n' "$OPTARG" >&2; usage >&2; exit 2 ;;
  esac
done

# Validate -d is a positive integer; bail clearly if not.
# Uses bash's built-in regex (=~) to avoid a long piped line that is
# easy to mangle on copy/paste.
if [[ ! "$DAYS" =~ ^[0-9]+$ ]] || (( DAYS < 1 )); then
  printf 'Error: -d expects a positive whole number of days (got "%s").\n' "$DAYS" >&2
  exit 2
fi

SINCE="$DAYS days ago"

# ---- helpers ---------------------------------------------------------------

divider() {
  printf '%s\n' "------------------------------------------------------------"
}

section() {
  printf '\n'
  divider
  printf '  %s\n' "$1"
  divider
}

have() { command -v "$1" >/dev/null 2>&1; }

# ---- header ----------------------------------------------------------------

printf '============================================================\n'
printf '  POWER / UPS SUMMARY\n'
printf '  host:      %s\n' "$(hostname)"
printf '  generated: %s\n' "$(date '+%Y-%m-%d %H:%M:%S %Z')"
printf '  ups:       %s\n' "$UPS_NAME"
printf '  log scan:  since %s\n' "$SINCE"
printf '============================================================\n'

# ---- 1. current state ------------------------------------------------------

section "CURRENT UPTIME & LOAD"
uptime

# ---- 2. boot history -------------------------------------------------------
# Each line is one boot. A NEW boot you didn't initiate == an unplanned
# power/cycling event. This is the single most useful signal for the
# NUC-cycling hypothesis.

section "BOOT HISTORY (newest last)"
if have journalctl; then
  journalctl --list-boots 2>/dev/null || printf 'journalctl --list-boots unavailable\n'
else
  printf 'journalctl not found\n'
fi

# ---- 3. login / reboot / shutdown history ----------------------------------
# `last -x` surfaces runlevel, reboot, and shutdown pseudo-users so you can
# see clean shutdowns vs. crashes. A reboot with no preceding shutdown line
# is a hard power loss / cycle.

section "REBOOT & SHUTDOWN HISTORY (last 15)"
if have last; then
  last -x --time-format iso 2>/dev/null | grep -Ei 'reboot|shutdown|runlevel' | head -n 15
  if [ "${PIPESTATUS[0]}" -ne 0 ]; then
    printf '(no matching entries)\n'
  fi
else
  printf 'last not found (package: util-linux / wtmp may be empty)\n'
fi

# ---- 4. power-relevant journal events --------------------------------------
# Greps the journal for kernel/UPS/power keywords. NUT logs battery/line
# transitions here (e.g. "UPS on battery", "UPS on line power", "low battery").
# Also catches thermal/PSU kernel messages.

section "POWER-RELEVANT LOG EVENTS (since $SINCE)"
if have journalctl; then
  journalctl --since "$SINCE" --no-pager 2>/dev/null \
    | grep -Ei 'on battery|on line|low battery|battery (is )?(low|critical)|power (fail|restore|loss)|UPS|ups\.status|forced shutdown|usbhid-ups|nut|upsmon|upssched' \
    | grep -Evi 'startup|started|starting|stopped|stopping' \
    | tail -n 40
  if [ "${PIPESTATUS[1]}" -ne 0 ]; then
    printf '(no power-relevant journal entries matched in window)\n'
  fi
else
  printf 'journalctl not found\n'
fi

# ---- 5. live UPS snapshot --------------------------------------------------
# Pulls the key fields from upsc rather than dumping all of them. If the
# device name is wrong or NUT is down, this section tells you immediately.

section "LIVE UPS SNAPSHOT (upsc $UPS_NAME)"
if have upsc; then
  if upsc "$UPS_NAME" >/dev/null 2>&1; then
    upsc "$UPS_NAME" 2>/dev/null | grep -E \
      '^(ups\.status|ups\.load|battery\.charge|battery\.runtime|battery\.voltage|input\.voltage|output\.voltage|ups\.realpower|ups\.realpower\.nominal|ups\.mfr|ups\.model|driver\.state):' \
      || printf '(connected, but expected fields not present — run `upsc %s` for full dump)\n' "$UPS_NAME"
  else
    printf 'ERROR: upsc could not reach "%s".\n' "$UPS_NAME"
    printf 'Devices NUT currently knows about:\n'
    upsc -l 2>/dev/null | sed 's/^/  /' || printf '  (upsc -l returned nothing — is nut-server / driver running?)\n'
  fi
else
  printf 'upsc not found (package: nut-client)\n'
fi

# ---- footer ----------------------------------------------------------------

printf '\n'
divider
printf '  END OF SUMMARY\n'
divider

# ----------------------------------------------------------------------------
# NOTES / NEXT STEPS (not active code):
#
# * runtime/load read as battery.runtime (seconds) and ups.load (% of capacity).
#   Remember the architecture goal is GRACEFUL SHUTDOWN, not long runtime — a
#   few minutes of runtime is success, not a problem.
#
# * To turn this into the deferred systemd timer logger, drop the human header
#   and append a single CSV/line-per-run to a logfile instead, e.g.:
#     echo "$(date -Is),$(upsc $UPS_NAME ups.status 2>/dev/null)" >> /var/log/ups-status.log
#   then wrap with a .service + .timer (OnCalendar=*:0/1 for every minute).
#
# * A future `--check` mode could exit non-zero when ups.status != "OL" so it
#   can feed a monitoring system. Left out here to keep this a pure report.
# ----------------------------------------------------------------------------
