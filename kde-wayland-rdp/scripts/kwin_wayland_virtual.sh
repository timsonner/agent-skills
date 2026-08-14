#!/bin/bash
# kwin_wayland --virtual. OpenGL needs a DRM node (vgem is enough).
# Do not set QT_QPA_PLATFORM=wayland — this process *is* the compositor.
unset QT_QPA_PLATFORM
export KWIN_COMPOSE="${KWIN_COMPOSE:-O2}"
export KWIN_WAYLAND_NO_PERMISSION_CHECKS=1
if [ -e /dev/dri/renderD128 ] || [ -e /dev/dri/card0 ]; then
  unset LIBGL_ALWAYS_SOFTWARE
  unset GALLIUM_DRIVER
  export MESA_LOADER_DRIVER_OVERRIDE="${MESA_LOADER_DRIVER_OVERRIDE:-kms_swrast}"
  echo "kwin: DRM present MESA_LOADER_DRIVER_OVERRIDE=$MESA_LOADER_DRIVER_OVERRIDE KWIN_COMPOSE=$KWIN_COMPOSE" >&2
elif [ -e /dev/dxg ]; then
  export GALLIUM_DRIVER="${GALLIUM_DRIVER:-d3d12}"
  export LIBGL_ALWAYS_SOFTWARE=0
  export LD_LIBRARY_PATH="/usr/lib/wsl/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
  echo "kwin: /dev/dxg only GALLIUM_DRIVER=$GALLIUM_DRIVER KWIN_COMPOSE=$KWIN_COMPOSE" >&2
else
  export LIBGL_ALWAYS_SOFTWARE=1
  export GALLIUM_DRIVER="${GALLIUM_DRIVER:-llvmpipe}"
  echo "kwin: no DRM, software GL KWIN_COMPOSE=$KWIN_COMPOSE" >&2
fi
exec /usr/bin/kwin_wayland \
  --virtual \
  --width "${KWIN_WIDTH:-1920}" \
  --height "${KWIN_HEIGHT:-1080}" \
  --no-lockscreen \
  "$@"
