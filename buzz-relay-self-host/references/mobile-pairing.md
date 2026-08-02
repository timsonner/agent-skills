# Mobile pairing (Desktop QR → phone)

## Symptom

Buzz Desktop **Settings → Mobile** fails with:

```text
WebSocket connection failed: HTTP error 404 Not Found
```

while the workspace relay is otherwise healthy.

## Diagnosis (matches block/buzz#2734 / #3291 / #3779)

1. Desktop reads NIP-11 from the community relay.
2. Sees **NIP-43** in `supported_nips` but **no** `pairing_relay_url`.
3. Falls back to legacy `wss://<relay-host>/pair`.
4. Main **`buzz-relay` does not serve `/pair`** → HTTP 404.
5. QR cannot be generated / phone cannot complete NIP-AB.

Confirm:

```bash
curl -sS -H 'Accept: application/nostr+json' https://<buzz-fqdn>/ | jq '{pairing_relay_url, supported_nips, version}'
# pairing_relay_url missing; 43 often present

curl -sS -D- -o/dev/null --http1.1 \
  -H 'Connection: Upgrade' -H 'Upgrade: websocket' \
  -H 'Sec-WebSocket-Version: 13' -H 'Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==' \
  https://<buzz-fqdn>/pair | head
# 404 = broken; 101 = pairing path OK
```

**Not Hermes.** Hermes gateway / agent key is unrelated to human Desktop↔phone pairing.

## What pairing actually is

- Phone reuses the **human Desktop keypair** (NIP-AB).
- QR is produced by **Buzz Desktop** on the laptop (ephemeral `nostrpair://…` session).
- Server must run a **pairing relay** (`buzz-pair-relay`) and advertise it.
- Do **not** mint QR codes from owner/agent private keys on the server.

Image already ships the binary: `/usr/local/bin/buzz-pair-relay` in `ghcr.io/block/buzz`.

## Option A — Self-host sidecar (preferred)

### 1) Compose services

Same image as the main relay; **entrypoint** must be the pair binary (not `command` alone):

```yaml
  pair:
    image: ${BUZZ_IMAGE:-ghcr.io/block/buzz:main}
    entrypoint: ["/usr/local/bin/buzz-pair-relay"]
    environment:
      BUZZ_PAIR_RELAY_BIND_ADDR: 0.0.0.0:5000
    restart: unless-stopped
    networks:
      - buzz-net
```

### 2) Path-proxy when the edge (Pangolin) only targets one backend port

If external TLS (Pangolin/Newt) points at guest `:3000` and cannot path-split easily, put a thin HTTP router on host `:3000`:

- `/pair*` → `pair:5000`
- everything else → `relay:3000`

Caddy example (`Caddyfile.pair`):

```caddy
:80 {
	handle /pair* {
		reverse_proxy pair:5000
	}
	handle {
		reverse_proxy relay:3000
	}
}
```

```yaml
  edge:
    image: caddy:2.8-alpine
    ports:
      - "${BUZZ_HTTP_PORT:-3000}:80"
    volumes:
      - ./Caddyfile.pair:/etc/caddy/Caddyfile:ro
    depends_on: [relay, pair]
    restart: unless-stopped
    networks: [buzz-net]
```

**Critical:** stop publishing the main relay’s host port `3000:3000` (use `expose: ["3000"]` only) so `edge` owns the host bind.

Templates: `templates/Caddyfile.pair`, `templates/compose-pair-edge.fragment.yml`.

### 3) Advertise in NIP-11

On the **main relay** env:

```env
BUZZ_PAIRING_RELAY_URL=wss://<buzz-fqdn>/pair
```

Restart/recreate relay so NIP-11 includes `pairing_relay_url`.

### 4) Alternate: separate subdomain

`wss://pair.<domain>` → guest `:5000` only, set:

```env
BUZZ_PAIRING_RELAY_URL=wss://pair.<domain>
```

No path proxy required; needs DNS + edge resource.

## Option B — Public pairing service (quick unblock)

```env
BUZZ_PAIRING_RELAY_URL=wss://pairing.buzz.xyz
```

Restart main relay only. Desktop uses Block’s pairing endpoint; phone still joins **your** community relay afterward. Good emergency workaround; prefer Option A for sovereignty.

## Verify

```bash
# or: scripts/verify-pair-endpoint.sh https://<buzz-fqdn>
curl -fsS https://<buzz-fqdn>/_liveness
curl -sS -H 'Accept: application/nostr+json' https://<buzz-fqdn>/ | jq .pairing_relay_url
# expect non-null URL

curl -sS -D- -o/dev/null --http1.1 \
  -H 'Connection: Upgrade' -H 'Upgrade: websocket' \
  -H 'Sec-WebSocket-Version: 13' -H 'Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==' \
  https://<buzz-fqdn>/pair | head
# expect: HTTP/1.1 101 Switching Protocols
# hanging after 101 on bare curl is normal (open WS)
```

Then laptop: **Desktop → Settings → Mobile → Try again** → scan QR → confirm SAS.

## Version mismatch note

Desktop 0.5.x QR vs older Mobile 0.4.12 can fail to decode even when `/pair` is 101 ([#3514](https://github.com/block/buzz/issues/3514)). Keep Desktop and mobile builds current/compatible.

## Operator mistakes

| Mistake | Result |
|---------|--------|
| Expect Hermes/CLI to print the pairing QR | Wrong layer — Desktop only |
| Put human/agent nsec into a homemade QR | Security + identity confusion |
| Enable compose Caddy LE **and** Pangolin TLS | Double TLS / broken paths |
| Leave relay bound to host `:3000` **and** start edge on `:3000` | Port conflict |
| Set `BUZZ_PAIRING_RELAY_URL` but never recycle relay | NIP-11 still missing field |
| Path-proxy `/pair` without WS upgrade on edge | Upgrade fails |

## Upstream

- https://github.com/block/buzz/issues/2734  
- https://engineering.block.xyz/blog/a-buzz-on-your-phone  
