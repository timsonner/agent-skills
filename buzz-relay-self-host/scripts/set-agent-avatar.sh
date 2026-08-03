#!/usr/bin/env bash
# Upload an image to the Buzz relay Blossom store and set it as the
# current identity's avatar (BUZZ_PRIVATE_KEY / agent key).
#
# Usage:
#   export BUZZ_RELAY_URL=https://buzz.example.com
#   export BUZZ_PRIVATE_KEY=<agent-hex-or-nsec>
#   ./set-agent-avatar.sh /path/to/avatar.png [--name Hermes] [--about 'bio']
#
# Prints only public profile JSON (no private key).
set -euo pipefail

FILE="${1:-}"
if [[ -z "$FILE" || ! -f "$FILE" ]]; then
  echo "usage: $0 /path/to/image.png [--name NAME] [--about TEXT]" >&2
  exit 2
fi
shift || true

NAME=""
ABOUT=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --name) NAME="${2:-}"; shift 2 ;;
    --about) ABOUT="${2:-}"; shift 2 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

: "${BUZZ_RELAY_URL:?set BUZZ_RELAY_URL}"
: "${BUZZ_PRIVATE_KEY:?set BUZZ_PRIVATE_KEY}"
CLI="${BUZZ_CLI_PATH:-buzz}"

upload_json="$("$CLI" upload file --file "$FILE")"
url="$(printf '%s' "$upload_json" | python3 -c 'import sys,json; print(json.load(sys.stdin)["url"])')"
echo "uploaded: $url"

args=(users set-profile --avatar "$url")
[[ -n "$NAME" ]] && args+=(--name "$NAME")
[[ -n "$ABOUT" ]] && args+=(--about "$ABOUT")
"$CLI" "${args[@]}"
echo "profile:"
"$CLI" users get
