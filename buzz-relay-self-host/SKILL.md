---
name: buzz-relay-self-host
description: "Use when self-hosting Block Buzz relay (Docker Compose) behind a reverse proxy, or wiring Hermes gateway as a community member."
version: 1.0.0
author: Tim Sonner
license: MIT
platforms: [linux]
metadata:
  hermes:
    tags: [buzz, nostr, relay, self-host, docker, proxmox, reverse-proxy, hermes-gateway, messaging]
    related_skills: [proxmox-system-administration, hermes-agent]
---

# Buzz Relay Self-Host (+ Hermes gateway)

Repeatable workflow for [Block Buzz](https://github.com/block/buzz) — a Nostr-based human+agent workspace relay — and optional **Hermes Agent** native gateway integration.

All examples use **placeholders only** (no real hostnames, IPs, keys, channel IDs, or operator identities). Keep site inventory in a private runbook outside this skill.

## What it is

- One Rust service: WebSocket relay + REST + web UI.
- Production deps: **Postgres**, **Redis**, **MinIO** (S3), git data volume.
- Official prod bundle: repo `deploy/compose/` (not the root dev `docker-compose.yml`).
- Image: `ghcr.io/block/buzz` — **pin a digest/tag** after first healthy boot.

## Placement policy

- Run the relay in a **dedicated utility guest** (VM/LXC), not on the bare hypervisor host.
- Publish **only** the relay HTTP port (default **3000**) to the edge proxy.
- Never expose Postgres / Redis / MinIO ports publicly.
- Prefer a non-root operator account on the guest (`ops` or similar) with docker group access.

Suggested guest baseline (adjust to load): 4 vCPU, 8G RAM, 80G disk, static LAN IP, auto-start on boot.

## Critical invariants

1. **`RELAY_URL` is the community identity**  
   Must match client URL **byte-for-byte** (scheme + host + port).  
   Public example: `wss://buzz.example.com`  
   Changing it later seeds a **new empty community**. Set the final public URL before real members/data.  
   For pure-local tests prefer `127.0.0.1` over `localhost` (agents often canonicalize localhost).

2. **Two Nostr identities at bootstrap**  
   - `BUZZ_RELAY_PRIVATE_KEY` — relay signing secret (64-hex).  
   - `RELAY_OWNER_PUBKEY` — owner **public** key (64-hex), not nsec.  
   Generate:
   ```bash
   docker run --rm --entrypoint /usr/local/bin/buzz-admin \
     ghcr.io/block/buzz:main generate-key
   ```
   Back up like TLS keys. Owner private key stays offline / in a secrets directory — not pasted into chat logs.

3. **Closed membership by default**  
   Typical flags: `BUZZ_REQUIRE_RELAY_MEMBERSHIP=true` and auth token requirements enabled.  
   Add members:
   ```bash
   ./run.sh add-member <npub-or-hex> --role member|admin
   ./run.sh list-members
   ```

4. **Public URL env vars must agree**
   ```env
   BUZZ_DOMAIN=buzz.example.com
   RELAY_URL=wss://buzz.example.com
   BUZZ_MEDIA_BASE_URL=https://buzz.example.com/media
   BUZZ_MEDIA_SERVER_DOMAIN=buzz.example.com
   BUZZ_CORS_ORIGINS=https://buzz.example.com
   BUZZ_AUTO_MIGRATE=true   # first boot / fresh DB
   ```

## Bring-up (guest)

```bash
git clone --depth 1 https://github.com/block/buzz.git
cd buzz/deploy/compose
cp .env.example .env
# Replace every CHANGE_ME_RANDOM with: openssl rand -hex 32
# Set relay private key + owner pubkey + public URL vars by hand
./run.sh start          # do NOT enable bundled Caddy when an external proxy terminates TLS
curl -fsS http://127.0.0.1:3000/_liveness   # expect: ok
./run.sh status
```

Pin image after success:
```env
BUZZ_IMAGE=ghcr.io/block/buzz@sha256:<digest>
```

Backup checklist: `./run.sh backup-hint` plus `.env`, owner key, Postgres, MinIO, git data volume.

## Reverse proxy / edge (Pangolin, Caddy, nginx, Traefik, …)

**Do not** stack the compose Caddy/Let’s Encrypt path when an external edge already terminates TLS.

| Setting | Value |
|---------|--------|
| Hostname | `buzz.example.com` |
| Backend target | `http://<guest-lan-ip>:3000` |
| WebSockets | **ON** |
| Health probe | `/_liveness` or `/_readiness` (prefer these over bare HTML `/`) |
| Path rewrite | none (root → root) |

### Auth wall: keep it OFF for the relay

Buzz Desktop, Hermes gateway, and other Nostr clients authenticate with **keypairs (NIP-42)**, not browser cookies. Edge SSO / PIN / shared password **breaks** them.

Browser-only apps (e.g. a Hermes dashboard) may keep SSO. **The Buzz relay resource must not.**

Verify unauthenticated edge:
```bash
curl -fsS https://buzz.example.com/_liveness
curl -fsS -H 'Accept: application/nostr+json' https://buzz.example.com/
# Expect NIP-11 JSON — not an HTML login page
```

Clients join Desktop with **`wss://buzz.example.com`** (not `https://`).

### WebSocket check note

```bash
curl -sS -D- -o/dev/null --http1.1 \
  -H 'Connection: Upgrade' -H 'Upgrade: websocket' \
  -H 'Sec-WebSocket-Version: 13' -H 'Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==' \
  https://buzz.example.com/
# Expect HTTP 101. Unauthenticated real clients may still get NIP-42 AUTH — expected.
```

curl without `--http1.1` may return 200 NIP-11 JSON; that alone is not proof WebSockets are broken.

## Desktop vs CLI

| Binary / package | Role | URL scheme |
|------------------|------|------------|
| `buzz` on PATH | Agent/script **CLI** (JSON I/O) | **`https://`** |
| Buzz Desktop | Human **GUI** | Join with **`wss://`** |

Bare `buzz` printing JSON help is normal — that is not the GUI.

## Onboarding humans (Desktop)

1. Install **Buzz Desktop** (not only the CLI package).
2. Identity:
   - **Daily path:** generate key in GUI → copy **public** npub/hex → guest `./run.sh add-member <pubkey> --role admin|member` → join `wss://…`.
   - **Owner path:** import owner secret from your offline secrets store (never paste private keys into agent chat).
3. Join URL exactly: `wss://buzz.example.com` (no path, no trailing slash, not `https://`).
4. **"Need invite"** on a closed relay = pubkey not on roster → `add-member`, then retry join / restart Desktop.

## Hermes integration (after relay healthy)

| Mode | When |
|------|------|
| ① Desktop runtime | Laptop: Settings → Runtimes → Hermes; prefer owner-only talk gates. |
| ② `buzz-acp` bridge | Buzz owns transport; server bridge → `hermes acp`. |
| **③ Native gateway** | **Preferred for always-on agents:** host `hermes-gateway` as a messaging platform. |

Details for mode ③: `references/hermes-gateway.md`.

### Mode ③ short checklist

1. Hermes install must include `plugins/platforms/buzz/` (update Hermes if `Connecting to buzz…` never appears).
2. Install **`buzz` CLI** on the **gateway host**. Public relay images often ship `buzz-admin` / `buzz-relay` only — build CLI if needed:
   ```bash
   cargo build --release --locked -p buzz-cli
   # install binary onto gateway host PATH, e.g. /usr/local/bin/buzz
   ```
3. Mint a **dedicated agent** keypair — not the human Desktop key, not `BUZZ_RELAY_PRIVATE_KEY`.
4. `./run.sh add-member <agent-pub> --role member`; join watched channels; optional profile name.
5. Put secrets in `~/.hermes/.env` **and ensure the gateway unit loads that file** (see reference).
6. Allowlist operators with **hex and npub** (deny logs show hex).
7. Restart gateway **outside** an in-gateway agent tool session (self-restart is often blocked).
8. Verify log line: `Buzz: connected … via websocket` / `✓ buzz connected`.

### Symptom: eyes / read reaction, no reply

1. Search gateway logs for `Unauthorized user`.
2. If present: missing **hex** on allowlist, gateway process missing env from `.env`, or process not fully recycled after env change.
3. Else inspect model/provider errors after a successful authorize.

Default recommendation: **only listed users** until you deliberately open the community.

## Operations

```bash
cd /path/to/buzz/deploy/compose
./run.sh status
./run.sh upgrade          # after pinning image digest
./run.sh list-members
./run.sh add-member <npub-or-hex> --role admin
./run.sh backup-hint
```

## Pitfalls

- **Human Desktop key reused as agent identity** → `BUZZ_PRIVATE_KEY` must be a dedicated agent secret, not the human Desktop nsec. Allowlist = human *public* hex/npub (who may talk). Verify with `buzz users get` (agent name/pubkey, not human). See `references/hermes-gateway.md`.

- **`buzz` CLI mistaken for Desktop** → JSON usage help; install/open the GUI package.
- **Temporary LAN `ws://` then public `wss://`** → different communities; set public `RELAY_URL` before real onboarding.
- **Caddy + external TLS double-termination** → skip compose Caddy behind the edge proxy.
- **Edge SSO on the relay** → breaks Nostr clients.
- **Health on `/` with SSO** → false unhealthy; use `/_liveness`.
- **curl WS without HTTP/1.1** → 200 JSON not 101; not always a failure.
- **"Need invite"** → closed roster; `add-member` the public key.
- **Unpinned `:main` image** → pin digest after healthy boot.
- **Compose dumps in chat** → leak DB/MinIO secrets; redact.
- **Human key as Hermes agent** → dedicated agent keypair (adapter scopes lock per relay+pubkey).
- **CLI missing from image** → build `-p buzz-cli`.
- **Hermes without buzz plugin** → update install.
- **Eyes / no reply** → hex allowlist + load `.env` into gateway unit + full process recycle.
- **Gateway restart from agent tools** → often blocked; use an external shell.

## Site-specific inventory (do not commit here)

Keep a **private** runbook next to the deploy with:

- Guest VMID/IP, FQDN, image digest
- Owner/agent **public** keys only (secrets stay in `chmod 600` files)
- Channel UUIDs and home channel
- Edge proxy resource IDs

## References

- `references/hermes-gateway.md` — native Hermes gateway wiring (placeholders only)
- Upstream blog: https://engineering.block.xyz/blog/run-your-own-buzz-relay
- Hermes messaging: https://hermes-agent.nousresearch.com/docs/user-guide/messaging/buzz
- Repo: https://github.com/block/buzz
