# Debian 13 is the base OS for every VM

The walkthroughs were written for Debian 12. The roles target Debian 13 instead, and `common` fails early on any other major version. Debian 13 has been stable since 9 August 2025, and Debian 12 left regular security support on 11 July 2026, with LTS until 30 June 2028 (all checked against debian.org/releases on 2026-10-04). Starting the roles on the old release would mean porting them within two years anyway.

Supporting both releases would double the testing for a lab that rebuilds its VMs from one template. The cost is that steps from the Debian 12 walkthroughs can't be copied straight into roles: package versions, repository names, and defaults have to be checked again for Debian 13, and each role README records what changed.
