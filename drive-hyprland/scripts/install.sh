#!/usr/bin/env bash
# Setup host input stack and/or symlink this skill into agent harness dirs.
set -euo pipefail

ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
HELPER="$ROOT/scripts/hypr-drive"

usage() {
  cat <<'EOF'
Usage: install.sh <host|harness|verify> [grok|claude|cursor|all]

  host      Install packages, fix /dev/uinput, start ydotoold (prints sudo steps)
  harness   Symlink this skill into ~/.grok/skills, ~/.claude/skills, ~/.cursor/skills
            Optional arg: grok | claude | cursor | all (default all)
  verify    Check hyprctl, wtype, grim, ydotool socket, /dev/uinput
EOF
}

have() { command -v "$1" >/dev/null 2>&1; }

pkg_add() {
  if have omarchy; then
    omarchy pkg add "$@"
  elif have pacman; then
    sudo pacman -S --needed --noconfirm "$@"
  else
    echo "install packages yourself: $*" >&2
    return 1
  fi
}

cmd_host() {
  echo "== packages =="
  pkg_add ydotool wtype grim || true

  echo "== input group =="
  if ! id -nG | tr ' ' '\n' | grep -qx input; then
    echo "Adding $USER to group input (log out/in afterwards):"
    echo "  sudo usermod -aG input $USER"
    sudo usermod -aG input "$USER"
  else
    echo "already in group input"
  fi

  echo "== /dev/uinput =="
  if [ -e /dev/uinput ]; then
    echo "before: $(ls -l /dev/uinput)"
    echo "Run if still root:root 600:"
    echo "  sudo udevadm control --reload"
    echo "  sudo chgrp input /dev/uinput"
    echo "  sudo chmod 0660 /dev/uinput"
    if [ -w /dev/uinput ]; then
      echo "uinput is writable by this user"
    else
      sudo udevadm control --reload || true
      sudo chgrp input /dev/uinput
      sudo chmod 0660 /dev/uinput
      echo "after: $(ls -l /dev/uinput)"
    fi
  else
    echo "/dev/uinput missing — load uinput: sudo modprobe uinput" >&2
  fi

  echo "== ydotoold =="
  systemctl --user reset-failed ydotool.service 2>/dev/null || true
  systemctl --user enable --now ydotool.service
  sleep 0.3
  systemctl --user --no-pager --full status ydotool.service || true
  sock="${XDG_RUNTIME_DIR:-/run/user/$UID}/.ydotool_socket"
  if [ -S "$sock" ]; then
    echo "socket ok: $sock"
  else
    echo "socket missing at $sock — see: journalctl --user -u ydotool.service -n 30" >&2
    exit 1
  fi
  chmod +x "$HELPER"
  echo "host setup done"
}

link_into() {
  local dest="$1"
  mkdir -p "$dest"
  local target="$dest/drive-hyprland"
  rm -rf "$target"
  ln -s "$ROOT" "$target"
  echo "linked $target -> $ROOT"
}

cmd_harness() {
  local which="${1:-all}"
  case "$which" in
    grok)   link_into "$HOME/.grok/skills" ;;
    claude) link_into "$HOME/.claude/skills" ;;
    cursor) link_into "$HOME/.cursor/skills" ;;
    all)
      link_into "$HOME/.grok/skills"
      link_into "$HOME/.claude/skills"
      link_into "$HOME/.cursor/skills"
      ;;
    *) usage >&2; exit 1 ;;
  esac
  chmod +x "$HELPER"
}

cmd_verify() {
  local ok=0
  have hyprctl && echo "hyprctl: $(hyprctl version 2>/dev/null | head -1 || echo present)" || { echo "FAIL hyprctl"; ok=1; }
  have python3 && echo "python3: ok" || { echo "FAIL python3"; ok=1; }
  have grim && echo "grim: ok" || { echo "FAIL grim"; ok=1; }
  have wtype && echo "wtype: ok" || { echo "FAIL wtype"; ok=1; }
  have ydotool && echo "ydotool: ok" || { echo "FAIL ydotool"; ok=1; }
  ls -l /dev/uinput
  if [ -w /dev/uinput ]; then echo "uinput: writable"; else echo "FAIL uinput not writable"; ok=1; fi
  sock="${XDG_RUNTIME_DIR:-/run/user/$UID}/.ydotool_socket"
  if [ -S "$sock" ]; then echo "socket: $sock"; else echo "FAIL no ydotool socket"; ok=1; fi
  systemctl --user is-active ydotool.service && echo "ydotool.service: active" || { echo "FAIL ydotool.service"; ok=1; }
  test -x "$HELPER" && echo "hypr-drive: $HELPER" || { echo "FAIL helper"; ok=1; }
  return "$ok"
}

cmd="${1:-}"
shift || true
case "$cmd" in
  host) cmd_host ;;
  harness) cmd_harness "${1:-all}" ;;
  verify) cmd_verify ;;
  ""|-h|--help|help) usage ;;
  *) usage >&2; exit 1 ;;
esac
