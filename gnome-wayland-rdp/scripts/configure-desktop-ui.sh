#!/bin/bash
# Apply GNOME Shell look-and-feel + favorites for headless RDP sessions.
# Safe to re-run; requires session D-Bus + gsettings.
set -u

export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
export HOME="${HOME:-/home/azureuser}"
export DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS:-unix:path=${XDG_RUNTIME_DIR}/bus}"
export XDG_CURRENT_DESKTOP="${XDG_CURRENT_DESKTOP:-GNOME}"
export XDG_SESSION_TYPE="${XDG_SESSION_TYPE:-wayland}"

if ! command -v gsettings >/dev/null 2>&1; then
  echo "configure-desktop-ui: gsettings missing" >&2
  exit 0
fi

if ! dbus-send --session --print-reply --dest=org.freedesktop.DBus \
      /org/freedesktop/DBus org.freedesktop.DBus.ListNames >/dev/null 2>&1; then
  echo "configure-desktop-ui: session bus not ready" >&2
  exit 0
fi

# User dirs (Desktop, Downloads, …)
if command -v xdg-user-dirs-update >/dev/null 2>&1; then
  xdg-user-dirs-update 2>/dev/null || true
fi

# Prefer dark Adwaita; readable fonts
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita' 2>/dev/null || true
gsettings set org.gnome.desktop.interface icon-theme 'Adwaita' 2>/dev/null || true
gsettings set org.gnome.desktop.interface cursor-theme 'Adwaita' 2>/dev/null || true
gsettings set org.gnome.desktop.interface font-name 'Adwaita Sans 11' 2>/dev/null || true
gsettings set org.gnome.desktop.interface document-font-name 'Adwaita Sans 11' 2>/dev/null || true
gsettings set org.gnome.desktop.interface monospace-font-name 'Adwaita Mono 11' 2>/dev/null || true
gsettings set org.gnome.desktop.interface enable-hot-corners true 2>/dev/null || true
gsettings set org.gnome.desktop.interface show-battery-percentage false 2>/dev/null || true
gsettings set org.gnome.desktop.interface clock-show-date true 2>/dev/null || true
gsettings set org.gnome.desktop.interface clock-show-seconds false 2>/dev/null || true

# Wallpaper: prefer shipped GNOME backgrounds (jxl/svg), fall back to solid accent
BG_LIGHT=""
BG_DARK=""
for cand in \
  /usr/share/backgrounds/gnome/adwaita-d.jxl \
  /usr/share/backgrounds/gnome/blobs-d.svg \
  /usr/share/backgrounds/gnome/drool-d.svg \
  /usr/share/backgrounds/gnome/adwaita-l.jxl \
  /usr/share/backgrounds/gnome/blobs-l.svg \
  /usr/share/backgrounds/gnome/drool-l.svg
do
  if [ -f "$cand" ]; then
    case "$cand" in
      *-d.*) [ -z "$BG_DARK" ] && BG_DARK="$cand" ;;
      *-l.*) [ -z "$BG_LIGHT" ] && BG_LIGHT="$cand" ;;
      *) [ -z "$BG_DARK" ] && BG_DARK="$cand"; [ -z "$BG_LIGHT" ] && BG_LIGHT="$cand" ;;
    esac
  fi
done
BG_DARK="${BG_DARK:-$BG_LIGHT}"
BG_LIGHT="${BG_LIGHT:-$BG_DARK}"

if [ -n "$BG_DARK" ]; then
  gsettings set org.gnome.desktop.background picture-uri "file://${BG_LIGHT}" 2>/dev/null || true
  gsettings set org.gnome.desktop.background picture-uri-dark "file://${BG_DARK}" 2>/dev/null || true
  gsettings set org.gnome.desktop.background picture-options 'zoom' 2>/dev/null || true
else
  # Deep blue solid if no packages
  gsettings set org.gnome.desktop.background picture-options 'none' 2>/dev/null || true
  gsettings set org.gnome.desktop.background primary-color '#1a5fb4' 2>/dev/null || true
  gsettings set org.gnome.desktop.background secondary-color '#1a5fb4' 2>/dev/null || true
fi

gsettings set org.gnome.desktop.screensaver picture-uri "file://${BG_DARK:-}" 2>/dev/null || true
gsettings set org.gnome.desktop.session idle-delay 0 2>/dev/null || true
gsettings set org.gnome.desktop.screensaver lock-enabled false 2>/dev/null || true
gsettings set org.gnome.desktop.notifications show-banners true 2>/dev/null || true

# Shell: favorites + not completely empty dash
# Desktop ids must match installed .desktop basenames
favs="["
sep=""
for app in \
  org.gnome.Nautilus.desktop \
  org.gnome.Console.desktop \
  org.gnome.TextEditor.desktop \
  org.gnome.Calculator.desktop \
  org.gnome.Settings.desktop
do
  if [ -f "/usr/share/applications/${app}" ] || [ -f "${HOME}/.local/share/applications/${app}" ]; then
    favs="${favs}${sep}'${app}'"
    sep=", "
  fi
done
favs="${favs}]"
if [ "$favs" != "[]" ]; then
  gsettings set org.gnome.shell favorite-apps "$favs" 2>/dev/null || true
fi

# Disable software update nags if schema exists
gsettings set org.gnome.software download-updates false 2>/dev/null || true
gsettings set org.gnome.software allow-updates false 2>/dev/null || true

# Mutter: slightly friendlier for remote
gsettings set org.gnome.mutter center-new-windows true 2>/dev/null || true
gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close' 2>/dev/null || true
gsettings set org.gnome.desktop.wm.preferences num-workspaces 3 2>/dev/null || true

# Nautilus: show some chrome
gsettings set org.gnome.nautilus.preferences default-folder-viewer 'list-view' 2>/dev/null || true
gsettings set org.gnome.nautilus.preferences show-hidden-files false 2>/dev/null || true

echo "configure-desktop-ui: applied (bg_dark=${BG_DARK:-none} favs=${favs})"
