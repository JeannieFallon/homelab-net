## Post-Mortem: The Ansible "Check Mode" Catch-22

**Date:** 2026-01-25  
**Component:** Ansible / SSH Configuration Role  

### Symptom
While performing a "dry run" using `ansible-playbook --check`, the playbook failed at the `authorized_key` task with the
following error:  
`"msg": "Either user must exist or you must provide full path to key file in check mode"`  

This occurred despite the user existing on the target system and the SSH keys being valid, effectively blocking the
verification of the remaining playbook tasks.

### Root Cause Analysis (RCA)
The issue was caused by **Check Mode Limitations & Module Ambiguity**.

* **Module Logic:** The `ansible.posix.authorized_key` module attempts to ensure the target `~/.ssh` directory exists
and has correct permissions (`0700`) before attempting to write the key.
* **The Check Mode Conflict:** In `--check` mode, Ansible does not perform filesystem changes. Because the module could
not "guarantee" the state of the parent directory during a simulation—especially when using `become: true` to resolve
home paths—it safely bailed out to avoid reporting a false success.
* **Redundancy:** The module's internal safety checks for directory existence are often incompatible with dry-runs when
those directories are managed within the same play.

### Resolution
1. **Strategic Pivot:** Verified the "plumbing" (SSH connectivity and Sudo elevation) via earlier tasks that passed
Check Mode successfully (e.g., Package Installation).
2. **Staged Live Run:** Shifted from a software simulation (`--check`) to a hardware-backed safety net. Leveraged a
**Proxmox Snapshot** to perform a live execution. 
3. **Execution:** The live run succeeded immediately, as the module was able to verify the filesystem state in
real-time, confirming the code logic was sound.

### Lessons Learned
* **Dry-Run Limits:** `--check` mode is a simulation, not a sandbox. It cannot always resolve logic that depends on
filesystem states that are intended to be created or modified earlier in the same playbook.
* **The "Snapshot" Workflow:** In a homelab environment, a Hypervisor-level snapshot is often a more reliable "test
environment" than a software-level dry run, providing a 10-second rollback path for failed automation.
* **Module Idempotency:** This failure highlighted the importance of understanding how specific Ansible modules verify
state; some modules require a "Real World" connection to validate their requirements.
