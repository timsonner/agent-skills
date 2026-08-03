# Hermes native gateway → Buzz

Sanitized wiring checklist. Replace every `<placeholder>`. Do not commit real keys, npubs, channel UUIDs, or hostnames into shared skills.

## Prerequisites

- Public relay healthy: `https://<buzz-fqdn>/_liveness` → `ok`
- Desktop join works at `wss://<buzz-fqdn>`
- `buzz` CLI on the host that runs `hermes-gateway`
- Hermes build with `plugins/platforms/buzz/`
- Dedicated agent Nostr keypair (member of the relay)


## Identity separation (critical)

Two different keypairs:

| Role | What it is | Where it lives |
|------|------------|----------------|
| **Operator (Desktop)** | Human who talks *to* the agent | Desktop only; **public** hex/npub on allowlist |
| **Agent (gateway)** | Who the bot *is* when posting | `BUZZ_PRIVATE_KEY` only — dedicated key |

**Wrong:** put the human Desktop nsec/hex secret into `BUZZ_PRIVATE_KEY` → gateway posts *as you*.  
**Right:** mint a new agent key; allowlist stays the human **public** ids.

### Verify (no secrets printed)

```bash
# Who is the CLI/gateway identity right now?
buzz users get
# expect agent display_name + agent pubkey — NOT your Desktop display name

# Cryptographic check: private key must derive to the agent pubkey you recorded
python3 - <<'PY'
from pathlib import Path
from coincurve import PrivateKey
env = dict(
    l.split("=", 1)
    for l in Path.home().joinpath(".hermes/.env").read_text().splitlines()
    if l.startswith("BUZZ_PRIVATE_KEY=")
)
sk = env["BUZZ_PRIVATE_KEY"].strip().strip('"')
derived = PrivateKey(bytes.fromhex(sk)).public_key.format(compressed=True)[1:].hex()
print("gateway_identity_pubkey", derived)
# Compare to the agent pubkey you saved at mint time — must match
# Must NOT equal your Desktop public hex
PY
```

If `buzz users get` shows your human profile, rotate: generate new agent key → `add-member` → update `BUZZ_PRIVATE_KEY` → recycle gateway.

## 1. Agent identity

```bash
# Prefer generating on the relay guest via buzz-admin
docker run --rm --entrypoint /usr/local/bin/buzz-admin \
  ghcr.io/block/buzz:main generate-key
# Store private material only in a secrets file / password manager
# Record the public hex for add-member + allowlists
```

On the relay guest:
```bash
cd /path/to/buzz/deploy/compose
./run.sh add-member <agent-public-hex-or-npub> --role member
```

Join rooms the agent should watch (CLI uses **https**):
```bash
export BUZZ_RELAY_URL=https://<buzz-fqdn>
export BUZZ_PRIVATE_KEY=<agent-secret>
buzz channels join --channel <channel-uuid>
buzz users set-profile --name <AgentDisplayName>
```

### Agent avatar

`--avatar` needs a **URL**. Upload to relay Blossom, then set profile:

```bash
# e.g. Nous mark from a Hermes install:
# /usr/local/lib/hermes-agent/website/static/img/nous-logo.png
AVATAR_URL="$(
  buzz upload file --file /path/to/avatar.png \
    | python3 -c 'import sys,json; print(json.load(sys.stdin)["url"])'
)"
buzz users set-profile \
  --name <AgentDisplayName> \
  --about '<short bio>' \
  --avatar "$AVATAR_URL"
buzz users get   # expect picture URL
```

Helper: `scripts/set-agent-avatar.sh` · full notes: `references/agent-profile-avatar.md`.

## 2. Hermes config (`~/.hermes/config.yaml`)

```yaml
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
        cli_path: /usr/local/bin/buzz   # or absolute path to buzz CLI
        channels:
          - <home-channel-uuid>
          # - <other-channel-uuid>
        home_channel: <home-channel-uuid>
        poll_interval: 4
        require_mention: true           # channels require @mention; DMs usually do not
        allow_all_users: false
        allowed_users:
          # Deny path typically compares HEX — list hex and npub for each operator
          - <operator-pubkey-hex-64>
          - <operator-npub1...>
```

## 3. Secrets (`~/.hermes/.env`)

```bash
BUZZ_RELAY_URL=https://<buzz-fqdn>
BUZZ_PRIVATE_KEY=<agent-hex-or-nsec>
BUZZ_CLI_PATH=/usr/local/bin/buzz
BUZZ_HOME_CHANNEL=<home-channel-uuid>
BUZZ_CHANNELS=<home-channel-uuid>,<other-channel-uuid>
BUZZ_ALLOW_ALL_USERS=false
BUZZ_ALLOWED_USERS=<operator-hex>,<operator-npub>
# Optional belt-and-suspenders with global gateway allowlist:
# GATEWAY_ALLOWED_USERS=<operator-hex>,<operator-npub>
```

Never commit `.env` or agent private keys.

## 4. Load `.env` into the gateway process

If the systemd unit only sets `HERMES_HOME`, allowlist checks may see an **empty** env even when the file exists on disk. Symptom: **eyes/read reaction, no text reply**, log line:

```text
Unauthorized user: <64-hex> (Name) on buzz
```

User systemd drop-in example:
```ini
# ~/.config/systemd/user/hermes-gateway.service.d/buzz-env.conf
[Service]
EnvironmentFile=-%h/.hermes/.env
```

Then:
```bash
systemctl --user daemon-reload
# Full process recycle so env is re-read (reload alone is often insufficient):
hermes gateway restart
# or: kill -TERM "$(systemctl --user show -p MainPID --value hermes-gateway.service)"
```

**Do not** restart the gateway from inside an in-gateway agent tool session when the platform blocks self-restart (SIGTERM would kill the running turn).

## 5. Verify

```bash
systemctl --user is-active hermes-gateway.service
# Log:
#   Buzz: connected to https://<buzz-fqdn> as <Name>, watching N channel(s) via websocket
#   ✓ buzz connected

# State file (plugin platforms may be missing from some status UIs):
python3 -c "import json,os;print(json.load(open(os.path.expanduser('~/.hermes/gateway_state.json'))).get('platforms'))"
```

In Desktop: **@Agent** in a watched channel (if `require_mention: true`) or DM the agent.

## 6. Troubleshooting

| Symptom | Likely cause | Fix |
|---------|--------------|-----|
| Eyes/read, no reply | `Unauthorized user: <hex>` | Add **hex** (+ npub) to allowlist; ensure unit loads `.env`; recycle process |
| Only Slack/other platforms connect | Missing buzz plugin | `hermes update` until `plugins/platforms/buzz/` exists |
| Connect fails / 401 | Wrong `RELAY_URL` / CLI scheme | CLI `https://`, Desktop `wss://`, same host; membership required |
| Agent can't send | Not a member / not joined channel | `add-member` + `buzz channels join` |
| Status UI omits Buzz | Plugin not listed in built-in table | Trust `gateway_state.json` + `gateway.log` |

## Security defaults (recommended)

- `allow_all_users: false`
- Explicit operator allowlist (hex + npub)
- `require_mention: true` in multi-user channels
- Dedicated agent key (never reuse human Desktop key or relay signing key)
- Secrets only in `chmod 600` files; rotate if leaked into logs/chat

## Alternatives

- **Desktop runtime:** laptop Settings → Runtimes → Hermes; keep owner-only tool approval expectations in mind (Buzz may auto-approve shell for owner agents).
- **buzz-acp:** server-side bridge to `hermes acp` when Buzz owns transport.

## Mobile pairing (out of scope for Hermes)

Human Desktop ↔ phone QR is **not** configured via Hermes. If Desktop Settings → Mobile 404s on `/pair`, fix the **relay** sidecar — see `references/mobile-pairing.md`.
