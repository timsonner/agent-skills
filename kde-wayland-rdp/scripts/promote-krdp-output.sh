#!/bin/bash
# KRdp --virtual-monitor adds a second head. Disable kwin --virtual's Virtual-0
# so windows and the panel live on the streamed output.
set -e
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
export DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS:-unix:path=${XDG_RUNTIME_DIR}/bus}"
export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-0}"
if [ "$(id -u)" = 0 ] && [ -n "${DESKTOP_USER:-}" ]; then
  exec runuser -u "$DESKTOP_USER" -- env XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" \
    DBUS_SESSION_BUS_ADDRESS="$DBUS_SESSION_BUS_ADDRESS" WAYLAND_DISPLAY="$WAYLAND_DISPLAY" "$0" "$@"
fi
kscreen-doctor output.Virtual-0.disable || true
kscreen-doctor output.Virtual-1920x1080@1.position.0,0 || true
kscreen-doctor -o 2>/dev/null | head -40
