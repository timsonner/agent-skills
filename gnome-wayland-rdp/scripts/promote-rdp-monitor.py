#!/usr/bin/env python3
"""Make the GRD 'Virtual remote monitor' the sole primary head.

Headless gnome-shell starts with Meta-0 (--virtual-monitor). When an RDP client
connects, GRD adds Meta-1 beside it; apps land on Meta-0 and the RDP view stays empty.
This script collapses layout to Meta-1 @ 0,0 primary when that connector appears.
Safe to run repeatedly (no-op if already sole primary on Meta-1).
"""
from __future__ import annotations

import os
import sys


def main() -> int:
    try:
        import dbus
    except ImportError:
        return 0

    bus_addr = os.environ.get("DBUS_SESSION_BUS_ADDRESS")
    if not bus_addr:
        return 0

    try:
        bus = dbus.SessionBus()
        obj = bus.get_object(
            "org.gnome.Mutter.DisplayConfig",
            "/org/gnome/Mutter/DisplayConfig",
        )
        iface = dbus.Interface(obj, "org.gnome.Mutter.DisplayConfig")
        serial, monitors, logical_monitors, _props = iface.GetCurrentState()
    except Exception:
        return 0

    remote = None
    for mon in monitors:
        connector = mon[0][0]
        product = mon[0][2]
        if connector == "Meta-1" or "remote" in str(product).lower():
            remote = mon
            break

    if remote is None:
        return 0

    # Already sole primary on remote?
    if len(logical_monitors) == 1:
        lm = logical_monitors[0]
        mons = lm[5]
        if mons and str(mons[0][0]) == str(remote[0][0]) and bool(lm[4]):
            return 0

    modes = remote[1]
    if not modes:
        return 0
    mode_id = modes[0][0]
    for mode in modes:
        props = mode[-1]
        try:
            if props.get("is-current") or props.get("is-preferred"):
                mode_id = mode[0]
                break
        except Exception:
            pass

    connector = str(remote[0][0])
    logical = [
        (
            dbus.Int32(0),
            dbus.Int32(0),
            dbus.Double(1.0),
            dbus.UInt32(0),
            True,
            [(connector, str(mode_id), dbus.Dictionary({}, signature="sv"))],
        )
    ]
    try:
        iface.ApplyMonitorsConfig(
            dbus.UInt32(serial),
            dbus.UInt32(1),  # temporary
            logical,
            dbus.Dictionary({}, signature="sv"),
        )
        print(f"promote-rdp-monitor: {connector} sole primary mode={mode_id}", flush=True)
    except Exception as exc:
        print(f"promote-rdp-monitor: apply failed: {exc}", file=sys.stderr, flush=True)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
