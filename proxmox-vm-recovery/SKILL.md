---
name: proxmox-vm-recovery
description: Handles troubleshooting and recovery of virtual machines (VMs) stuck during boot on Proxmox VE hosts. Activate this skill when a user reports a VM (especially Windows 11/UEFI guest) failing to boot, hanging at the OVMF logo, or showing "Start boot option" loading screens.
author: Tim Sonner
license: MIT
---

# Proxmox VE VM Recovery & Stuck Boot Troubleshooting Guide

This skill provides step-by-step instructions for troubleshooting and recovering virtual machines that fail to boot or hang during the boot loader phase (such as Windows 11 guest UEFI boot loop/freeze).

---

## 1. Safety Guidelines & Rules
- **ALWAYS** stop the VM (`qm stop <vmid>`) before performing any virtual disk manipulations, mounting, or editing.
- **ALWAYS** back up existing disk files (especially `efidisk0` and configuration files) before deleting or replacing them.
- **NEVER** run write operations on a VM disk while the VM is running, as this will lead to data corruption.
- **DO NOT** attempt to mount BitLocker encrypted partitions directly; instead, focus on repair of the unencrypted EFI bootloader partition or configuration settings.

---

## 2. Diagnosis Workflow

### Step 2.1: Gather VM and Host Context
Run commands to inspect the VM configuration and status:
- Check current power status:
  ```bash
  qm status <vmid>
  ```
- Print the VM config:
  ```bash
  qm config <vmid>
  ```

### Step 2.2: Capture VM Console Screen
Since headless VMs do not show errors directly on the host console, capture a VM screenshot to see what it is displaying:
1. Run a QEMU Monitor screendump command via the Proxmox API client (`pvesh`):
   ```bash
   pvesh create /nodes/{node_name}/qemu/{vmid}/monitor --command "screendump /root/screenshot.ppm"
   ```
2. Convert the PPM screenshot to PNG for easier viewing:
   ```bash
   python3 -c "from PIL import Image; img = Image.open('/root/screenshot.ppm'); img.save('/root/screenshot.png')"
   ```
3. View the screenshot to identify if:
   - It is stuck at the BIOS/UEFI boot options menu or showing a loader log (e.g. `BdsDxe: loading Boot0009 "Windows Boot Manager" ... Start boot option`).
   - It shows a Blue Screen of Death (BSOD) or guest kernel panic.
   - It is showing a black screen or CD/DVD boot prompt.

---

## 3. Recovery Workflows

### Method A: Recreating the EFI Disk & Secure Boot Keys (Windows 11 / UEFI Guests)
If the guest is stuck loading the Windows Boot Manager (`bootmgfw.efi`) or at "Start boot option", the EFI variable store / Secure Boot keys on `efidisk0` may be corrupted. Recreate them:

1. **Stop the VM:**
   ```bash
   qm stop <vmid>
   ```
2. **Back up the old EFI disk file** (usually located in `/var/lib/vz/images/<vmid>/`):
   ```bash
   cp /var/lib/vz/images/<vmid>/vm-<vmid>-disk-0.qcow2 /var/lib/vz/images/<vmid>/vm-<vmid>-disk-0.qcow2.bak
   ```
3. **Remove the EFI disk configuration:**
   ```bash
   qm set <vmid> --delete efidisk0
   ```
4. **Move the old EFI disk file out of the way:**
   ```bash
   mv /var/lib/vz/images/<vmid>/vm-<vmid>-disk-0.qcow2 /var/lib/vz/images/<vmid>/vm-<vmid>-disk-0.qcow2.old
   ```
5. **Recreate a clean EFI disk with pre-enrolled keys:**
   ```bash
   qm set <vmid> --efidisk0 local:0,efitype=4m,pre-enrolled-keys=1
   ```
   *(Note: Adjust the storage name `local` if the VM uses a different storage backend).*
6. **Start the VM and verify boot:**
   ```bash
   qm start <vmid>
   ```

### Method B: CPU Type Adjustment (Hybrid Host CPUs)
If the guest hangs or crashes early in kernel boot due to hybrid host CPU scheduling (e.g., Intel 12th/13th/14th Gen P-cores and E-cores mismatching flags):
1. Change the guest CPU model to a standard QEMU type (e.g., `x86-64-v3` or `qemu64`):
   ```bash
   qm set <vmid> --cpu x86-64-v3
   ```
2. Restart the VM and check if it boots.

### Method C: Inspecting/Mounting the Guest Partition Table
If the boot files are suspected to be missing or corrupted:
1. Ensure the VM is stopped.
2. Load the network block device kernel module:
   ```bash
   modprobe nbd max_part=8
   ```
3. Attach the virtual disk:
   ```bash
   qemu-nbd --connect=/dev/nbd0 /var/lib/vz/images/<vmid>/vm-<vmid>-disk-1.qcow2
   ```
4. List the partitions:
   ```bash
   fdisk -l /dev/nbd0
   ```
5. Mount the EFI System Partition (FAT32, usually partition 1) read-only:
   ```bash
   mkdir -p /mnt/guest_efi && mount -o ro /dev/nbd0p1 /mnt/guest_efi
   ```
6. Check that the boot files exist:
   ```bash
   ls -la /mnt/guest_efi/EFI/Microsoft/Boot/
   ```
7. Clean up and disconnect:
   ```bash
   umount /mnt/guest_efi
   qemu-nbd --disconnect /dev/nbd0
   ```
