# Hermes native gateway → Buzz

Sanitized wiring checklist. Replace every `<placeholder>`. Do not commit real keys, npubs, channel UUIDs, or hostnames into shared skills.

## Prerequisites

- Public relay healthy: `https://<buzz-fqdn>/_liveness` → `ok`
- Desktop join works at `wss://<buzz-fqdn>`
- `buzz` CLI on the host that runs `hermes-gateway`
- Hermes build with `plugins/platforms/buzz/`
- Dedicated agent Nostr keypair (member of the relay)

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
