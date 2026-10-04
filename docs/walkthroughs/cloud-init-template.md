# Debian 13 Cloud-Init Template on Proxmox

> **Draft, not yet run on hardware.** Written from the Proxmox and Debian docs and from memory. Each step has a
> **Status** line; change it to "verified on hardware" or correct the step when it's run on the Proxmox host. Tracked
> in [#13](https://github.com/JeannieFallon/homelab-net/issues/13).

## Goal

Build a Debian 13 VM template on the Proxmox host from the official cloud image, and clone VMs from it. Every clone
boots with a static IP and the `ansible` user, reachable over SSH with key-only login and passwordless sudo. That's the
contract the Ansible roles expect ([ADR 0003](../adr/0003-roles-configure-existing-vms.md)).

This replaces the interactive install in [`create_vm.md`](create_vm.md) for every VM in the lab, including the control
node.

## Requirements

- Proxmox VE host with WAN access and a shell (SSH or the web UI's *Shell*)
- The workstation's SSH public key, copied to the Proxmox host (for example as `~/workstation.pub`)
- A block of static addresses on the lab VLAN outside the router's DHCP pool, and the VLAN's gateway and DNS server

The examples use VM ID `9000` for the template, `local-lvm` for storage, and documentation addresses (`192.0.2.0/24`).
Substitute your own.

## Procedure

### 1. Download and check the image

On the Proxmox host:

```bash
cd /var/lib/vz/template
wget https://cloud.debian.org/images/cloud/trixie/latest/debian-13-genericcloud-amd64.qcow2
wget https://cloud.debian.org/images/cloud/trixie/latest/SHA512SUMS
sha512sum --check --ignore-missing SHA512SUMS
```

`genericcloud` is the image for VMs on a hypervisor like Proxmox: it drops drivers for physical hardware and expects
cloud-init to configure it.

**Status:** unverified. The file name and `SHA512SUMS` were checked against cloud.debian.org on 2026-10-04.

### 2. Create the VM shell

The hardware settings carry over from `create_vm.md`: q35, OVMF with an EFI disk, VirtIO SCSI single, `host` CPU, and
the guest agent enabled.

```bash
qm create 9000 --name debian13-template --ostype l26 \
  --machine q35 --bios ovmf --efidisk0 local-lvm:1,efitype=4m,pre-enrolled-keys=0 \
  --cpu host --cores 2 --memory 2048 \
  --scsihw virtio-scsi-single \
  --net0 virtio,bridge=vmbr0 \
  --agent enabled=1 \
  --serial0 socket --vga serial0
```

- **No VLAN tag on `net0`.** The router port already assigns untagged traffic to the lab VLAN, and tagging it again in
  Proxmox is the double-tagging failure from the
  [January post-mortem](../post-mortem/20260102_vlan-tags.md).
- `pre-enrolled-keys=0` leaves Secure Boot keys out of the EFI disk, so the image boots whether or not its bootloader
  is signed for them.
- The serial console is where cloud images send boot output. Use **Console > xterm.js** in the web UI to watch it.

**Status:** unverified (from memory and the `qm(1)` man page).

### 3. Import the image as the boot disk

```bash
qm disk import 9000 /var/lib/vz/template/debian-13-genericcloud-amd64.qcow2 local-lvm
qm config 9000 | grep unused
```

The import shows up as `unused0`, for example `local-lvm:vm-9000-disk-1` (`disk-0` is the EFI disk). Attach it with
the same disk options as `create_vm.md`, and boot from it:

```bash
qm set 9000 --scsi0 local-lvm:vm-9000-disk-1,discard=on,ssd=1,iothread=1
qm set 9000 --boot order=scsi0
```

On older Proxmox releases, `qm disk import` is `qm importdisk`.

**Status:** unverified.

### 4. Add the cloud-init drive and user

```bash
qm set 9000 --scsi1 local-lvm:cloudinit
qm set 9000 --ciuser ansible --sshkeys ~/workstation.pub
```

Cloud-init creates only the `ansible` user. The `common` role creates the personal admin later. Don't set
`--cipassword`; the account is key-only.

**Status:** unverified. To confirm on hardware: the Debian cloud image gives the cloud-init default user passwordless
sudo (from memory).

### 5. Convert to a template

```bash
qm template 9000
```

**Status:** unverified.

## Per-clone checklist

For each new VM. Example: the monitoring server at `192.0.2.20`, VM ID `110`.

1. Full clone:

   ```bash
   qm clone 9000 110 --name mon-01 --full
   ```

2. Grow the disk. The cloud image is about 3 GB; cloud-init grows the root partition to fill the disk on first boot:

   ```bash
   qm resize 110 scsi0 32G
   ```

3. Set a static IP outside the DHCP pool, with the VLAN gateway, and the DNS server:

   ```bash
   qm set 110 --ipconfig0 ip=192.0.2.20/24,gw=192.0.2.1 --nameserver 192.0.2.1
   ```

4. Start it and wait for cloud-init to finish (watch the serial console):

   ```bash
   qm start 110
   ```

5. Check the contract from the workstation (or from the control node, once its key is in the template):

   ```bash
   ssh ansible@192.0.2.20 'sudo -n true && echo passwordless sudo ok'
   ```

6. Add the VM to `playbooks/inventory/hosts.yml` under the group for its job.

**Status:** unverified. To confirm on hardware: cloud-init grows the root partition after `qm resize` (from memory),
and `qemu-guest-agent` isn't in the image (from memory; `common` installs it, after which the VM's IP shows on its
*Summary* tab).

## Later: add the control node's key

After the control node is bootstrapped (see the
[`ansible_control` role README](../../playbooks/roles/ansible_control/README.md#building-the-control-node)), add its
public key to the template, keeping the workstation's key:

```bash
cat ~/workstation.pub ~/control-node.pub > ~/template-keys.pub
qm set 9000 --sshkeys ~/template-keys.pub
```

Clones made after this accept SSH from both the workstation and the control node. Clones made before it only have the
workstation's key.

**Status:** unverified. To confirm on hardware: `qm set` changes cloud-init options on a template (from memory).

## Resources

- [Proxmox VE: Cloud-Init Support](https://pve.proxmox.com/wiki/Cloud-Init_Support)
- [Debian Official Cloud Images](https://cloud.debian.org/images/cloud/)
- [`qm(1)` manual](https://pve.proxmox.com/pve-docs/qm.1.html)
