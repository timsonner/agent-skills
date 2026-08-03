# Always-on agents via buzz-acp (mode ②)

Placeholder-only recipe. Keep live FQDNs, keys, and channel UUIDs in a **private** runbook.

## When to use

| Mode | What | Always on? |
|------|------|------------|
| ① Desktop runtime | Buzz Desktop spawns `hermes-acp` / other ACP on the **laptop** | No |
| **② buzz-acp bridge** | Server harness + ACP agent over stdio | **Yes** |
| ③ Native gateway | Hermes `gateway` + Buzz platform plugin | **Yes** (full Hermes features) |

Use **②** when you want ACP-shaped agents (Hermes ACP, Copilot CLI ACP, goose, …) that stay online without Desktop open.  
Use **③** for the main Hermes channel bot (memory, cron, multi-platform).  
**Do not** reuse the same Nostr key for ② and ③.

## Architecture

```
Clients → wss://<buzz-fqdn>
       → buzz-acp (systemd on agent host)
       → ACP agent stdio (hermes acp | copilot --acp --stdio | …)
       → buzz CLI for outbound tools
```

## Prerequisites

- Healthy public relay + membership for a **dedicated agent** key
- `buzz` CLI on the agent host PATH
- ACP agent binary that speaks [ACP](https://agentclientprotocol.com/) over stdio
- Build `buzz-acp`: `cargo build --release -p buzz-acp` (from [block/buzz](https://github.com/block/buzz))

## Identity

```bash
# Mint agent key (save secret once)
docker run --rm --entrypoint /usr/local/bin/buzz-admin \
  ghcr.io/block/buzz:main generate-key

# On relay guest
./run.sh add-member <agent-pub-hex> --role member

export BUZZ_RELAY_URL=https://<buzz-fqdn>
export BUZZ_PRIVATE_KEY=<agent-secret>
buzz channels join --channel <channel-uuid>
buzz users set-profile --name '<DisplayName>' --about '<bio>'
# Avatar: see agent-profile-avatar.md (strip PNG metadata before upload)
```

## Env template (secrets file, mode 600)

```bash
BUZZ_RELAY_URL=wss://<buzz-fqdn>
BUZZ_PRIVATE_KEY=<agent-secret>
BUZZ_ACP_AGENT_OWNER=<owner-hex-64>          # owner-only talk gate
BUZZ_ACP_RESPOND_TO=owner-only
BUZZ_ACP_RELAY_OBSERVER=true                 # optional Desktop activity frames

# --- Hermes ACP backend ---
# BUZZ_ACP_AGENT_COMMAND=/path/to/hermes
# BUZZ_ACP_AGENT_ARGS=acp
# BUZZ_ACP_MODEL=nous:anthropic/claude-sonnet-5   # or xai-oauth:grok-4.5, etc.
# Discover: BUZZ_ACP_AGENT_COMMAND=... buzz-acp models

# --- Copilot CLI ACP backend ---
# BUZZ_ACP_AGENT_COMMAND=/usr/local/bin/copilot
# BUZZ_ACP_AGENT_ARGS=--acp,--stdio,--effort=medium,--allow-all-tools,--allow-all-paths
# BUZZ_ACP_MODEL=gpt-5.4
# Note: Copilot catalog may NOT include Nous-only names (e.g. gpt-5.6-luna).
# Effort is fixed at server start for Copilot ACP (not per session).

BUZZ_ACP_SESSION_TITLE=<DisplayName>
BUZZ_CLI_PATH=/usr/local/bin/buzz
PATH=/usr/local/bin:/usr/bin:/bin
# HERMES_HOME=...   # if using Hermes ACP on that host
```

List models for the configured agent:

```bash
export BUZZ_ACP_AGENT_COMMAND=... BUZZ_ACP_AGENT_ARGS=...
buzz-acp models
# or: buzz-acp models --json
```

## systemd (user unit sketch)

```ini
[Unit]
Description=Buzz ACP bridge (always-on agent)
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
EnvironmentFile=-%h/.config/buzz-acp/agent.env
ExecStart=/usr/local/bin/buzz-acp
Restart=on-failure
RestartSec=5

[Install]
WantedBy=default.target
```

```bash
systemctl --user daemon-reload
systemctl --user enable --now buzz-acp-<name>.service
journalctl --user -u buzz-acp-<name>.service -f
```

Healthy log signals: `agent initialized`, `connected to relay`, `discovered N channel(s)`, `presence set to online`.

## Naming & profile

Prefer descriptive display names, e.g. `Hermes-Copilot-GPT-5.4-<suffix>` or `Hermes-Nous-Sonnet-<suffix>`.

```bash
buzz users set-profile --name '…' --about '…' --avatar 'https://<buzz-fqdn>/media/<sha>.png'
```

## Security

- **Owner-only** (or tight allowlist) — headless ACP often auto-approves tools.
- Dedicated Nostr key per agent; never human Desktop key; never gateway adapter key.
- Secrets only in `chmod 600` files; never in public skills/repos.
- Prefer a locked-down OS user for production bridges.

## Multiple always-on agents

One key + one env + one unit per agent (or harness multi-agent flags if you accept shared process complexity). Join only the channels each agent should hear.

## Related

- Mode ③ native gateway: `references/hermes-gateway.md`
- Avatars: `references/agent-profile-avatar.md`
- Mobile pairing (Desktop QR): `references/mobile-pairing.md`
- Upstream: https://github.com/block/buzz/tree/main/crates/buzz-acp  
- Hermes Buzz modes: https://hermes-agent.nousresearch.com/docs/integrations/buzz  
- Copilot ACP server: https://docs.github.com/en/copilot/reference/copilot-cli-reference/acp-server  
