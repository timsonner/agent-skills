#!/bin/bash
# Make sure the default Plasma panel is full-width on the only live screen.
set -e
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
export HOME="${HOME:-/home/${DESKTOP_USER:-kdeuser}}"
export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-0}"
export DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS:-unix:path=${XDG_RUNTIME_DIR}/bus}"
if [ "$(id -u)" = 0 ] && [ -n "${DESKTOP_USER:-}" ]; then
  exec runuser -u "$DESKTOP_USER" -- env XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" HOME="/home/$DESKTOP_USER" \
    WAYLAND_DISPLAY="$WAYLAND_DISPLAY" DBUS_SESSION_BUS_ADDRESS="$DBUS_SESSION_BUS_ADDRESS" "$0" "$@"
fi
gdbus call --session --dest org.kde.plasmashell --object-path /PlasmaShell \
  --method org.kde.PlasmaShell.evaluateScript '
var ps = panels();
if (ps.length === 0) {
  var panel = new Panel;
  panel.location = "bottom";
  panel.height = 48;
  panel.addWidget("org.kde.plasma.kickoff");
  panel.addWidget("org.kde.plasma.pager");
  panel.addWidget("org.kde.plasma.icontasks");
  panel.addWidget("org.kde.plasma.marginsseparator");
  panel.addWidget("org.kde.plasma.systemtray");
  panel.addWidget("org.kde.plasma.digitalclock");
  panel.addWidget("org.kde.plasma.showdesktop");
  ps = panels();
}
var p = ps[0];
p.floating = false;
p.hiding = "none";
p.location = "bottom";
p.height = 48;
try { p.lengthMode = "fill"; } catch (e) {}
p.minimumLength = screenGeometry(0).width;
p.maximumLength = screenGeometry(0).width;
p.length = screenGeometry(0).width;
print("panel w=" + p.length + " float=" + p.floating);
'
kwriteconfig6 --file plasmashellrc --group PlasmaViews --group "Panel 2" --key floating 0 || true
