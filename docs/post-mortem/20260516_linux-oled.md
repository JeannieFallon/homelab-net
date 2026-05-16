# Post-Mortem: OLED Brightness Stuck at Maximum

**Date:** 2026-05-16

**Component:** Debian 13 / Intel i915 Driver / Samsung Galaxy Book2 360 (NP730QED-KA1US) AMOLED Panel

## Symptom

After a fresh Debian 13 install with GNOME, the AMOLED display was locked at
full brightness with no way to dim it. The GNOME Settings brightness slider
appeared and could be dragged, but had no visible effect on the panel. Fn
brightness keys were also non-responsive.

## Root Cause Analysis (RCA)

The issue was a **phantom backlight interface** exposed by the i915 driver.
*   **Sysfs Interface:** `/sys/class/backlight/intel_backlight/` was present
    and writable. Reading `max_brightness` returned 65535 and `brightness`
    could be set to any value in range.
*   **Panel Response:** Writes to `brightness` succeeded silently but produced
    no visible change on the OLED panel.
*   **Underlying Cause:** Intel's i915 driver defaults to PWM-based backlight
    control, which works for traditional LCD panels but not for the DPCD
    (DisplayPort Configuration Data) backlight control path used by Samsung's
    AMOLED panel. The driver exposes the sysfs interface unconditionally, even
    when it isn't actually wired to a working hardware control path.

> **The Conflict:** Software stack saw a valid backlight device and reported
success on all operations. Hardware never received a command it understood.
This is the worst class of bug: it lies about working.

## Diagnostic Pattern

The signature for identifying a phantom sysfs interface:
1.  Interface exists at expected path (`/sys/class/backlight/<device>/`)
2.  Reads return plausible values
3.  Writes succeed (no permission errors, no I/O errors)
4.  No corresponding hardware state change

When sysfs accepts writes silently with no effect, suspect the driver is
exposing an interface it doesn't actually own.

## Resolution

Instructed the i915 driver to use DPCD backlight control via kernel parameter.
1.  Edit `/etc/default/grub` and append `i915.enable_dpcd_backlight=3` to the
    `GRUB_CMDLINE_LINUX_DEFAULT` value:
    ```
    GRUB_CMDLINE_LINUX_DEFAULT="quiet splash i915.enable_dpcd_backlight=3"
    ```
2.  Regenerate the active GRUB config:
    ```bash
    sudo update-grub
    ```
3.  Reboot.

After reboot, the Fn brightness keys worked correctly.

## Lessons Learned
*   **Phantom sysfs interfaces are a known failure mode on Linux**, especially
    around display, audio, and power management subsystems where the kernel
    has to guess at hardware capabilities. Writes succeeding does not imply
    hardware responded.
*   **OLED panels on Intel platforms frequently need explicit DPCD backlight
    mode.** The `i915.enable_dpcd_backlight` parameter has documented values
    of `1` (force enable), `2` (force disable), and `3` (auto-enable when
    supported). Value `3` is the safest default.
*   **Test post-install hardware quirks from the live USB when possible.** The
    `intel_backlight` phantom behavior was visible from the live environment
    and could have been confirmed with `i915.enable_dpcd_backlight=3` via a
    one-shot GRUB edit before committing to install. Knowing the fix in
    advance would have shortened the post-install recovery window.
