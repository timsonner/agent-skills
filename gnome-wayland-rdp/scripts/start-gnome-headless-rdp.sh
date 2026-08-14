#!/bin/bash
# GNOME 46+/50 Wayland headless + gnome-remote-desktop (run as the desktop user).
# Credentials come from the environment — do not bake lab passwords into this file.
set -u

DESKTOP_USER="${DESKTOP_USER:-$(id -un)}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
export HOME="${HOME:-/home/$DESKTOP_USER}"
export LIBSEAT_BACKEND="${LIBSEAT_BACKEND:-seatd}"
export XDG_SESSION_TYPE=wayland
export XDG_CURRENT_DESKTOP=GNOME

WIDTH="${GNOME_WIDTH:-1920}"
HEIGHT="${GNOME_HEIGHT:-1080}"
RDP_PORT="${GNOME_RDP_PORT:-3389}"
RDP_USER="${GNOME_RDP_USER:-$DESKTOP_USER}"
RDP_PASS="${GNOME_RDP_PASS:-}"
TLS_DIR="${GRD_TLS_DIR:-$HOME/.local/share/gnome-remote-desktop}"
LOG_GS=/tmp/gnome-shell-headless.log
LOG_GRD=/tmp/grd-headless.log

if [ -z "$RDP_PASS" ]; then
  echo "start-gnome-headless-rdp: set GNOME_RDP_PASS" >&2
  exit 2
fi

mkdir -p "$XDG_RUNTIME_DIR" "$TLS_DIR"
chmod 700 "$XDG_RUNTIME_DIR"

if [ ! -s "$TLS_DIR/tls.crt" ] || [ ! -s "$TLS_DIR/tls.key" ]; then
  openssl req -x509 -newkey rsa:2048 -sha256 -nodes \
    -keyout "$TLS_DIR/tls.key" -out "$TLS_DIR/tls.crt" \
    -days 3650 -subj "/CN=localhost"
  chmod 600 "$TLS_DIR/tls.key"
fi

# Session bus — wait until ListNames works (socket existence is not enough).
rm -f "$XDG_RUNTIME_DIR/bus"
dbus-daemon --session --address="unix:path=${XDG_RUNTIME_DIR}/bus" --fork
export DBUS_SESSION_BUS_ADDRESS="unix:path=${XDG_RUNTIME_DIR}/bus"

i=0
while [ "$i" -lt 30 ]; do
  if [ -S "$XDG_RUNTIME_DIR/bus" ] && \
     dbus-send --session --print-reply --dest=org.freedesktop.DBus \
       /org/freedesktop/DBus org.freedesktop.DBus.ListNames >/dev/null 2>&1; then
    break
  fi
  i=$((i + 1))
  sleep 0.2
done

if ! dbus-send --session --print-reply --dest=org.freedesktop.DBus \
      /org/freedesktop/DBus org.freedesktop.DBus.ListNames >/dev/null 2>&1; then
  echo "ERROR: session dbus not ready at $XDG_RUNTIME_DIR/bus" >&2
  ls -la "$XDG_RUNTIME_DIR" >&2 || true
  exit 1
fi

# Do not use set -e around grdctl — some commands warn/exit 1 on a live daemon.
grdctl --headless rdp set-tls-key "$TLS_DIR/tls.key" || true
grdctl --headless rdp set-tls-cert "$TLS_DIR/tls.crt" || true
grdctl --headless rdp set-credentials "$RDP_USER" "$RDP_PASS" || true
grdctl --headless rdp set-port "$RDP_PORT" || true
grdctl --headless rdp enable 2>/dev/null || true
gsettings set org.gnome.desktop.remote-desktop.rdp.headless enable true 2>/dev/null || true
gsettings set org.gnome.desktop.remote-desktop.rdp tls-cert "$TLS_DIR/tls.crt" 2>/dev/null || true
gsettings set org.gnome.desktop.remote-desktop.rdp tls-key "$TLS_DIR/tls.key" 2>/dev/null || true

if command -v pipewire >/dev/null 2>&1; then
  pgrep -u "$(id -u)" -x pipewire >/dev/null 2>&1 || nohup pipewire >/tmp/pipewire.log 2>&1 &
fi
if command -v wireplumber >/dev/null 2>&1; then
  pgrep -u "$(id -u)" -x wireplumber >/dev/null 2>&1 || nohup wireplumber >/tmp/wireplumber.log 2>&1 &
fi
sleep 0.5

if ! pgrep -u "$(id -u)" -x gnome-shell >/dev/null 2>&1; then
  nohup gnome-shell --wayland --headless --virtual-monitor="${WIDTH}x${HEIGHT}" \
    >"$LOG_GS" 2>&1 &
fi

i=0
while [ "$i" -lt 60 ]; do
  if pgrep -u "$(id -u)" -x gnome-shell >/dev/null 2>&1; then
    break
  fi
  if grep -q 'Failed to connect to session bus' "$LOG_GS" 2>/dev/null; then
    echo "ERROR: gnome-shell could not connect to session bus" >&2
    tail -30 "$LOG_GS" >&2 || true
    exit 1
  fi
  i=$((i + 1))
  sleep 0.5
done
sleep 2

if ! pgrep -u "$(id -u)" -x gnome-shell >/dev/null 2>&1; then
  echo "ERROR: gnome-shell failed to stay up" >&2
  tail -50 "$LOG_GS" >&2 || true
  exit 1
fi

if [ -x /usr/local/bin/configure-desktop-ui.sh ]; then
  /usr/local/bin/configure-desktop-ui.sh >>/tmp/desktop-ui.log 2>&1 || true
fi

if [ -x /usr/local/bin/promote-rdp-monitor.py ]; then
  (
    while pgrep -u "$(id -u)" -x gnome-shell >/dev/null 2>&1; do
      python3 /usr/local/bin/promote-rdp-monitor.py >>/tmp/promote-rdp-monitor.log 2>&1 || true
      sleep 3
    done
  ) &
fi

_NOFUSE="${NOFUSEABORT_SO:-/usr/local/lib/libnofuseabort.so}"
if [ -f "$_NOFUSE" ]; then
  export LD_PRELOAD="${_NOFUSE}${LD_PRELOAD:+:$LD_PRELOAD}"
fi
export LIBGL_ALWAYS_SOFTWARE="${LIBGL_ALWAYS_SOFTWARE:-1}"

start_grd() {
  nohup env LD_PRELOAD="${LD_PRELOAD:-}" LIBGL_ALWAYS_SOFTWARE="$LIBGL_ALWAYS_SOFTWARE" \
    /usr/libexec/gnome-remote-desktop-daemon --headless >>"$LOG_GRD" 2>&1 &
  sleep 2
}

if ! pidof gnome-remote-desktop-daemon >/dev/null 2>&1; then
  start_grd
fi

(
  while pgrep -u "$(id -u)" -x gnome-shell >/dev/null 2>&1; do
    sleep 4
    if ! pidof gnome-remote-desktop-daemon >/dev/null 2>&1; then
      echo "$(date -Is) grd restart" >>/tmp/grd-watchdog.log
      start_grd
    fi
  done
) &

echo "GNOME headless + GRD  port=${RDP_PORT}  user=${RDP_USER}"
ss -lntp 2>/dev/null | grep -E ":${RDP_PORT}\\b" || true
grep -E 'RDP server|ERROR|Failed|started|auth|NLA' "$LOG_GRD" 2>/dev/null | tail -15 || true
