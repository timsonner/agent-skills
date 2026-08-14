#!/bin/bash
set -e
DESKTOP_USER="${DESKTOP_USER:-kdeuser}"
if [ "$(id -u)" = 0 ] && id "$DESKTOP_USER" >/dev/null 2>&1; then
  exec runuser -u "$DESKTOP_USER" -- env DESKTOP_USER="$DESKTOP_USER" \
    KRDP_USER="${KRDP_USER:-}" KRDP_PASS="${KRDP_PASS:-}" KRDP_PORT="${KRDP_PORT:-}" \
    "$0" "$@"
fi
export HOME="${HOME:-/home/$DESKTOP_USER}"
export LANG="${LANG:-C.UTF-8}"
export LC_ALL="${LC_ALL:-C.UTF-8}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-0}"
export DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS:-unix:path=${XDG_RUNTIME_DIR}/bus}"
export QT_QPA_PLATFORM=wayland
export XDG_SESSION_TYPE=wayland
export XDG_CURRENT_DESKTOP=KDE
export QT_FORCE_STDERR_LOGGING=1
export QT_ASSUME_STDERR_HAS_CONSOLE=1
export QT_LOGGING_RULES="${QT_LOGGING_RULES:-krdp*.debug=true;kpipewire*.debug=true}"
export KWIN_WAYLAND_NO_PERMISSION_CHECKS=1
# Same GBM/Mesa device as KWin. Software llvmpipe cannot import vgem dmabufs.
unset LIBGL_ALWAYS_SOFTWARE
unset GALLIUM_DRIVER
export MESA_LOADER_DRIVER_OVERRIDE="${MESA_LOADER_DRIVER_OVERRIDE:-kms_swrast}"
if [ -f /usr/share/vulkan/icd.d/lvp_icd.x86_64.json ]; then
  export VK_ICD_FILENAMES="${VK_ICD_FILENAMES:-/usr/share/vulkan/icd.d/lvp_icd.x86_64.json}"
fi
# H.264 off while KWin only offers dmabufs → empty frames ("windows don't move").
unset KRDP_DISABLE_H264

RDP_USER="${KRDP_USER:-$DESKTOP_USER}"
RDP_PASS="${KRDP_PASS:-}"
RDP_PORT="${KRDP_PORT:-3389}"
WIDTH="${KWIN_WIDTH:-1920}"
HEIGHT="${KWIN_HEIGHT:-1080}"
TLS_DIR="${KRDP_TLS_DIR:-$HOME/.local/share/krdpserver}"
if [ -z "$RDP_PASS" ]; then
  echo "start-krdp: set KRDP_PASS" >&2
  exit 2
fi
if [ ! -s "$TLS_DIR/krdp.crt" ] || [ ! -s "$TLS_DIR/krdp.key" ]; then
  mkdir -p "$TLS_DIR"
  openssl req -x509 -newkey rsa:2048 -sha256 -nodes \
    -keyout "$TLS_DIR/krdp.key" -out "$TLS_DIR/krdp.crt" \
    -days 3650 -subj "/CN=localhost"
  chmod 600 "$TLS_DIR/krdp.key"
fi

PRELOAD_SO="${KRDP_AUTODETECT_SO:-/usr/local/lib/libkrdp-autodetect.so}"
if [ -f "$PRELOAD_SO" ]; then
  export LD_PRELOAD="${PRELOAD_SO}${LD_PRELOAD:+:$LD_PRELOAD}"
  echo "krdp: NetworkAutoDetect + pointer preload" >&2
fi
echo "krdp: user=$RDP_USER port=$RDP_PORT display=$WAYLAND_DISPLAY" >&2
exec krdpserver -u "$RDP_USER" -p "$RDP_PASS" --port "$RDP_PORT" \
  --certificate "$TLS_DIR/krdp.crt" --certificate-key "$TLS_DIR/krdp.key" \
  --virtual-monitor "${WIDTH}x${HEIGHT}@1" --plasma --quality "${KRDP_QUALITY:-40}"
