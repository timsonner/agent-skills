---
name: proxmox-system-administration
description: Use when operating a Proxmox VE host with least-privilege workflows, reusable VM templates, and auditable hardening.
---

# Proxmox System Administration (Sanitized, Least-Privilege First)

## Overview

This skill standardizes Proxmox operations using a strict boundary model:

- Host root is for hypervisor control-plane actions only (`qm`, `pct`, `pvesh`, storage/network ops).
- Workloads run inside dedicated VMs/LXCs.
- Guest services run as non-root service accounts.
- Reuse existing guests first; create new guests only when isolation/capacity requires it.

All examples in this skill are intentionally sanitized and use placeholders (no real hostnames, IPs, usernames, credentials, IDs, or internal paths).

## When to Use

Use this skill when you need to:
- Provision or manage Proxmox VMs/LXCs.
- Enforce least privilege across host and guests.
- Build repeatable utility-VM workflows.
- Add hardened service deployment patterns.

Do not use this skill for:
- Non-Proxmox cloud operations.
- App-only coding tasks unrelated to infrastructure lifecycle.

## Operating Policy

1. **Root boundary:** host root is only for Proxmox lifecycle/admin commands.
2. **Guest boundary:** operational workloads execute in guests, not on the host.
3. **Account boundary:** use dedicated non-root operator + service users in guests.
4. **Reuse-first:** inspect existing fleet before creating new guests.
5. **Auditability:** deterministic naming, tagged purpose, and verifiable checks.
6. **Network minimization:** expose only required ports and paths.

## Plan -> Test -> Iterate Workflow

1. **Plan**
   - Define role, resources, network mode, and rollback/verification gates.
2. **Test each phase**
   - Verify every stage before moving on (template, clone/start, bootstrap, service).
3. **Iterate minimally on failures**
   - Apply the smallest corrective change, re-run the failed check, then continue.

Avoid giant one-shot scripts when phased commands provide better traceability and rollback.

## Discovery First (Always)

```bash
qm list
pct list
pvesm status
ip -br a
pvesh get /nodes
pvesh get /nodes/$(hostname)/status
```

## Template and VM Pattern (Sanitized)

### 1) Build/refresh a cloud-init template

```bash
TEMPLATE_ID=<template-id>
CLOUD_IMAGE=<path-to-cloud-image>

qm create "$TEMPLATE_ID" --name <template-name> --memory <mb> --cores <n> --net0 virtio,bridge=<bridge>
qm importdisk "$TEMPLATE_ID" "$CLOUD_IMAGE" <storage>
qm set "$TEMPLATE_ID" --scsihw virtio-scsi-pci --scsi0 <storage>:vm-${TEMPLATE_ID}-disk-0
qm set "$TEMPLATE_ID" --ide2 <storage>:cloudinit
qm set "$TEMPLATE_ID" --boot c --bootdisk scsi0
qm set "$TEMPLATE_ID" --serial0 socket --vga serial0
qm set "$TEMPLATE_ID" --agent 1
qm template "$TEMPLATE_ID"
```

### 2) Clone into a service VM

```bash
VM_ID=<vm-id>
VM_NAME=<service-vm-name>

qm clone <template-id> "$VM_ID" --name "$VM_NAME" --full 1
qm set "$VM_ID" --memory <mb> --cores <n>
qm set "$VM_ID" --ipconfig0 ip=dhcp
qm set "$VM_ID" --ciuser <operator-user>
qm set "$VM_ID" --sshkeys <authorized-keys-path>
qm set "$VM_ID" --agent 1
qm start "$VM_ID"
```

### 3) Optional network pinning with placeholders

```bash
qm set <vm-id> --ipconfig0 ip=<service-ip>/<cidr>,gw=<gateway-ip>
qm reboot <vm-id>
```

## Guest Hardening Baseline

Inside the guest:

```bash
sudo useradd -m -s /bin/bash <operator-user> || true
sudo usermod -aG sudo <operator-user> || true
sudo useradd -r -s /usr/sbin/nologin <service-user> || true
```

Recommended SSH posture:
- Disable root SSH login.
- Disable password authentication.
- Enforce key-based auth.

## Service Deployment Baseline

- Keep app listener on loopback by default.
- Front with authenticated reverse proxy only when required.
- Run service via systemd as the dedicated service account.
- Use systemd hardening directives (`NoNewPrivileges`, `ProtectSystem`, `PrivateTmp`, etc.) where compatible.

## Backup/Snapshot Baseline

- Create snapshot before invasive changes.
- Use scheduled Proxmox backups with retention policy.
- Verify backup jobs are visible and policy is applied.

## Common Pitfalls

1. Running workload tasks directly on host root.
2. Reusing root or shared users for service runtime.
3. Skipping verification between provisioning phases.
4. Exposing service ports publicly when loopback + proxy would suffice.
5. Treating approval-gated blocks as transient errors instead of hard stops.

## Verification Checklist

- [ ] Existing guests reviewed before new provisioning.
- [ ] New guest has role-based name/ID and clear purpose.
- [ ] Workload executes in guest, not on host root.
- [ ] Dedicated non-root service account in use.
- [ ] SSH hardening applied and validated.
- [ ] Service health checks pass.
- [ ] Snapshot/backup policy configured and verified.
