#!/bin/bash
# Run via execns (or unconfined + --device) so this process can open DRM.
set -e
DESKTOP_USER="${DESKTOP_USER:-kdeuser}"
if [ "$(id -u)" = 0 ] && id "$DESKTOP_USER" >/dev/null 2>&1; then
  if [ -n "${XDG_RUNTIME_DIR:-}" ]; then
    chown "$DESKTOP_USER:$DESKTOP_USER" "$XDG_RUNTIME_DIR" /tmp/.X11-unix 2>/dev/null || true
  fi
  exec runuser -u "$DESKTOP_USER" -- env DESKTOP_USER="$DESKTOP_USER" "$0" "$@"
fi
export HOME="${HOME:-/home/$DESKTOP_USER}"
export LANG="${LANG:-C.UTF-8}"
export LC_ALL="${LC_ALL:-C.UTF-8}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
export XDG_SESSION_TYPE=wayland
export XDG_CURRENT_DESKTOP=KDE
export DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS:-unix:path=${XDG_RUNTIME_DIR}/bus}"
export KWIN_COMPOSE="${KWIN_COMPOSE:-O2}"
export KWIN_WAYLAND_NO_PERMISSION_CHECKS=1
unset LIBGL_ALWAYS_SOFTWARE
unset GALLIUM_DRIVER
export MESA_LOADER_DRIVER_OVERRIDE="${MESA_LOADER_DRIVER_OVERRIDE:-kms_swrast}"
export MESA_GL_VERSION_OVERRIDE="${MESA_GL_VERSION_OVERRIDE:-4.5}"
export KWIN_DRM_USE_MODIFIERS="${KWIN_DRM_USE_MODIFIERS:-0}"
export KWIN_SKIP_CLOSE_ANIMATION=1
export KWIN_EFFECTS_FORCE_ANIMATIONS=0
export KWIN_USE_BUFFER_AGE=1
if [ -f /usr/share/vulkan/icd.d/lvp_icd.x86_64.json ]; then
  export VK_ICD_FILENAMES="${VK_ICD_FILENAMES:-/usr/share/vulkan/icd.d/lvp_icd.x86_64.json}"
fi
unset LIBGL_DEBUG
unset EGL_LOG_LEVEL
export QT_LOGGING_RULES="${QT_LOGGING_RULES:-*.debug=false}"
export QT_FORCE_STDERR_LOGGING=1
export QT_ASSUME_STDERR_HAS_CONSOLE=1
unset QT_QPA_PLATFORM
mkdir -p "$XDG_RUNTIME_DIR" /tmp/.X11-unix
chmod 700 "$XDG_RUNTIME_DIR" || true
chmod 1777 /tmp/.X11-unix || true
rm -f "$XDG_RUNTIME_DIR"/wayland-0 "$XDG_RUNTIME_DIR"/wayland-0.lock
WRAPPER="${KWIN_WRAPPER:-/usr/local/bin/kwin_wayland_virtual.sh}"
if [ ! -x "$WRAPPER" ]; then
  WRAPPER="$(dirname "$0")/kwin_wayland_virtual.sh"
fi
echo "kwin-gl: user=$(id -un) dri=$(ls /dev/dri 2>/dev/null | tr '\n' ' ') compose=$KWIN_COMPOSE" >&2
exec "$WRAPPER" --xwayland --socket wayland-0
