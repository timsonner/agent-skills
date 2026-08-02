#!/usr/bin/env bash
# Verify Buzz mobile pairing path + NIP-11 advertisement.
# Usage: verify-pair-endpoint.sh https://buzz.example.com
set -euo pipefail
BASE="${1:-}"
if [[ -z "$BASE" ]]; then
  echo "usage: $0 https://<buzz-fqdn>" >&2
  exit 2
fi
BASE="${BASE%/}"
PAIR_URL="${BASE}/pair"

echo "== liveness =="
curl -fsS --max-time 10 "${BASE}/_liveness"
echo

echo "== NIP-11 pairing_relay_url =="
nip11="$(curl -fsS --max-time 15 -H 'Accept: application/nostr+json' "${BASE}/")"
if command -v jq >/dev/null 2>&1; then
  echo "$nip11" | jq '{pairing_relay_url, version, has_nip43: (any(.supported_nips[]?; . == 43))}'
  pru="$(echo "$nip11" | jq -r '.pairing_relay_url // empty')"
else
  echo "$nip11" | head -c 500; echo
  pru="$(printf '%s' "$nip11" | sed -n 's/.*"pairing_relay_url"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)"
fi
if [[ -z "${pru}" ]]; then
  echo "FAIL: pairing_relay_url missing from NIP-11" >&2
  exit 1
fi
echo "pairing_relay_url=${pru}"

echo "== WebSocket upgrade ${PAIR_URL} =="
hdrs="$(curl -sS --max-time 8 -D- -o/dev/null --http1.1 \
  -H 'Connection: Upgrade' \
  -H 'Upgrade: websocket' \
  -H 'Sec-WebSocket-Version: 13' \
  -H 'Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==' \
  "${PAIR_URL}" || true)"
printf '%s\n' "$hdrs" | head -20
if printf '%s' "$hdrs" | head -1 | grep -q '101'; then
  echo "OK: 101 Switching Protocols"
  exit 0
fi
if printf '%s' "$hdrs" | head -1 | grep -q '404'; then
  echo "FAIL: /pair still 404 — deploy buzz-pair-relay + path route" >&2
  exit 1
fi
echo "FAIL: expected HTTP 101 on /pair" >&2
exit 1
