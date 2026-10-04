# Prometheus is installed from the Debian package, not an upstream release

The original walkthrough installed a pinned upstream Prometheus tarball with a hand-written systemd unit and system user. We install the `prometheus` package from Debian 13 instead, accepting a major version behind upstream (2.53.3 vs. 3.15.0 as of 2026-09-30, checked against packages.debian.org and GitHub releases) in exchange for Debian security updates, a packaged service unit and user, and no hand-managed binary upgrades.

Revisit this if a needed feature exists only in Prometheus 3.x. Switching means owning the binary, unit, user, and every upgrade.
