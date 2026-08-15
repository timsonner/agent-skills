---
name: buzz-hermes-gateway
description: "Use when connecting Hermes Agent gateway to a Block Buzz community (CLI, allowlist/hex, env load, mention rules)."
version: 1.0.0
author: Tim Sonner
license: MIT
platforms: [linux]
metadata:
  hermes:
    tags: [buzz, nostr, hermes-gateway, messaging, allowlist]
    related_skills: [buzz-relay-self-host, hermes-agent]
---

# Hermes gateway ↔ Buzz

Focused skill for wiring **Hermes Agent** as a native messaging member of a [Block Buzz](https://github.com/block/buzz) community.

For standing up the relay itself (compose, reverse proxy, Desktop onboarding), use **`buzz-relay-self-host`**.

All examples use **placeholders only**. Keep real keys, FQDNs, and channel UUIDs in a private runbook.

## Architecture

```
Buzz Desktop (wss://) ─┐
buzz CLI (https://)   ─┼→ reverse proxy (TLS + WebSockets, no login wall)
Hermes gateway        ─┘         → relay :3000 → Postgres/Redis/MinIO
```

- CLI and gateway use **`https://<buzz-fqdn>`**.
- Desktop joins with **`wss://<buzz-fqdn>`**.
- Same host; different schemes by client type.


## Identity separation

| | Operator (human) | Agent (Hermes) |
|--|------------------|----------------|
| Purpose | Talks *to* the bot | *Is* the bot in channels |
| Secret | Stays in Desktop only | `BUZZ_PRIVATE_KEY` |
| Public id | On `allowed_users` | Member of relay; posts as this pubkey |

Never put the human Desktop private key in `BUZZ_PRIVATE_KEY`.  
Quick check: `buzz users get` must show the agent profile, not the human.

## Prerequisites

1. Relay publicly healthy: `curl -fsS https://<buzz-fqdn>/_liveness`
2. Hermes install includes `plugins/platforms/buzz/` (otherwise `hermes update`)
3. `buzz` CLI on the gateway host PATH (or set `cli_path` / `BUZZ_CLI_PATH`)
4. Dedicated agent keypair + `add-member` on the relay
5. Agent has joined each watched channel

### Building the CLI when the image lacks it

Public `ghcr.io/block/buzz` images often include `buzz-admin` / `buzz-relay` only:

```bash
# From a full clone of github.com/block/buzz
cargo build --release --locked -p buzz-cli
install -m 755 target/release/buzz /usr/local/bin/buzz
```

Ensure `PATH` includes the Rust toolchain bin dir inside build containers (`/usr/local/cargo/bin`).

## Config pattern

```yaml
# ~/.hermes/config.yaml
display:
  platforms:
    buzz:
      interim_assistant_messages: false
      tool_progress: off

gateway:
  platforms:
    buzz:
      enabled: true
      extra:
        relay_url: https://<buzz-fqdn>
        cli_path: /usr/local/bin/buzz
        channels: [<home-channel-uuid>, <other-channel-uuid>]
        home_channel: <home-channel-uuid>
        poll_interval: 4
        require_mention: true
        allow_all_users: false
        allowed_users:
          - <operator-hex-64>
          - <operator-npub1...>
```

```bash
# ~/.hermes/.env  (never commit)
BUZZ_RELAY_URL=https://<buzz-fqdn>
BUZZ_PRIVATE_KEY=<agent-secret>
BUZZ_CLI_PATH=/usr/local/bin/buzz
BUZZ_HOME_CHANNEL=<home-channel-uuid>
BUZZ_CHANNELS=<csv-of-channel-uuids>
BUZZ_ALLOW_ALL_USERS=false
BUZZ_ALLOWED_USERS=<operator-hex>,<operator-npub>
```

## Load env into the gateway unit

Allowlist/env vars must be present in the **running gateway process**, not only on disk:

```ini
# ~/.config/systemd/user/hermes-gateway.service.d/buzz-env.conf
[Service]
EnvironmentFile=-%h/.hermes/.env
```

```bash
systemctl --user daemon-reload
hermes gateway restart   # full recycle; bare reload often skips .env re-read
```

Restart from a **host shell / SSH / separate TUI** — not from tools running inside the gateway session when self-restart is blocked.

## Allowlist rules that matter

| Rule | Why |
|------|-----|
| Prefer `allow_all_users: false` | Closed talk gate for agents |
| List **hex and npub** | Deny path often logs/compares **hex** |
| Match the human Desktop identity | Wrong key → eyes reaction, no reply |
| Recycle after changes | Stale process keeps old allowlist |

### Eyes / read, no reply

```bash
rg 'Unauthorized user' ~/.hermes/logs/gateway.log | tail
```

Fix: add the denied **hex**, ensure `EnvironmentFile` drop-in, recycle gateway.

## Verify

```bash
# Connected?
rg -n 'Buzz: connected|✓ buzz connected' ~/.hermes/logs/gateway.log | tail

# Plugin platforms may be missing from some status UIs — trust state file:
python3 -c "import json,os;print(json.load(open(os.path.expanduser('~/.hermes/gateway_state.json'))).get('platforms'))"
```

Desktop: **@AgentName** in a watched channel (if mentions required) or DM.

Cron / home delivery: `deliver=buzz` uses `home_channel`.

## Status UI quirks

- `hermes status` messaging table may list only **built-in** platforms (e.g. Slack) while Buzz (plugin) is connected.
- Dashboard API may omit plugin platforms under `gateway_platforms`. Prefer `gateway_state.json` + `gateway.log`.

## Pitfalls

- **Human Desktop key reused as agent identity** → `BUZZ_PRIVATE_KEY` must be a dedicated agent secret, not the human Desktop nsec. Allowlist = human *public* hex/npub (who may talk). Verify with `buzz users get` (agent name/pubkey, not human). See `references/hermes-gateway.md`.
- npub-only allowlist without hex
- `.env` not loaded by systemd unit
- `reload` instead of process recycle after env edits
- Gateway self-restart from agent tools
- CLI `https://` vs Desktop `wss://` confusion
- Agent not joined to channel / not on membership roster
- Edge SSO in front of the relay (breaks NIP-42 clients)

## Security defaults

- Dedicated agent key; secrets mode `600`
- Operator allowlist only
- Channel `@mention` required in multi-user rooms
- Never paste nsec / private keys into chat or public skills
- Site inventory (FQDN, UUIDs, pubkeys) stays in a private runbook

## Mobile pairing

Not a Hermes gateway task. Desktop QR / `/pair` 404 → deploy `buzz-pair-relay` on the **Buzz relay** host. See sibling skill `buzz-relay-self-host` → `references/mobile-pairing.md`.

## Agent avatar / profile

```bash
# BUZZ_* = agent identity; strip PNG metadata if upload 422s
AVATAR_URL="$(buzz upload file --file /tmp/avatar-clean.png | python3 -c 'import sys,json; print(json.load(sys.stdin)["url"])')"
buzz users set-profile --name <AgentDisplayName> --avatar "$AVATAR_URL"
```

Details: `buzz-relay-self-host/references/agent-profile-avatar.md`.

## Always-on ACP (server)

For agents that stay online without Desktop, use **buzz-acp** + a dedicated key + `hermes acp` or `copilot --acp --stdio`. See `buzz-relay-self-host/references/buzz-acp-bridge.md`. Do not reuse the native gateway agent key.

## See also

- `hermes-harness` — drive `hermes` CLI (`-z`, `chat -q`, ACP) from another agent
- `buzz-relay-self-host` — relay compose, reverse proxy, Desktop onboarding, mobile pairing, avatars, buzz-acp
- `buzz-relay-self-host/references/hermes-gateway.md` — expanded wiring table
- https://hermes-agent.nousresearch.com/docs/user-guide/messaging/buzz
