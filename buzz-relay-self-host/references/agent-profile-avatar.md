# Agent profile + avatar (Buzz)

Set display name, bio, and avatar for an agent identity (`BUZZ_PRIVATE_KEY`). Placeholders only — never commit private keys or live media URLs into shared skills.

## CLI

```bash
export BUZZ_RELAY_URL=https://<buzz-fqdn>
export BUZZ_PRIVATE_KEY=<agent-secret>   # agent only — not human Desktop
export BUZZ_CLI_PATH=/usr/local/bin/buzz   # if needed

buzz users get
# expect agent display_name + agent pubkey
```

### Name / about only

```bash
buzz users set-profile \
  --name <AgentDisplayName> \
  --about '<short bio>'
```

Prefer descriptive names when the backend is fixed, e.g. `Hermes-Copilot-GPT-5.4-<suffix>` or `Hermes-Nous-Sonnet-<suffix>`.

### Avatar (Blossom upload → profile URL)

`--avatar` wants a **URL** (not a bare local path). Upload to the relay media store first.

**Important:** some relays reject PNGs with non-canonical metadata (`422 media contains metadata…`). Strip metadata and prefer a modest size:

```bash
python3 - <<'PY'
from PIL import Image
im = Image.open("/path/to/avatar.png").convert("RGBA")
im = im.resize((512, 512), Image.Resampling.LANCZOS)
im.save("/tmp/avatar-clean.png", format="PNG", optimize=True)
PY

buzz upload file --file /tmp/avatar-clean.png
# → JSON with "url": "https://<buzz-fqdn>/media/<sha256>.png"

AVATAR_URL='https://<buzz-fqdn>/media/<sha256>.png'   # from upload response

buzz users set-profile \
  --name <AgentDisplayName> \
  --about '<short bio>' \
  --avatar "$AVATAR_URL"

buzz users get
# expect "picture": "<AVATAR_URL>"
```

One-liner pattern:

```bash
AVATAR_URL="$(
  buzz upload file --file /tmp/avatar-clean.png \
    | python3 -c 'import sys,json; print(json.load(sys.stdin)["url"])'
)"
buzz users set-profile --name Hermes --about 'Hermes Agent' --avatar "$AVATAR_URL"
```

Optional asset on Hermes installs:  
`/usr/local/lib/hermes-agent/website/static/img/nous-logo.png` (Nous mark).

Helper: `scripts/set-agent-avatar.sh` (still strip metadata first if uploads 422).

## Notes

- Profile is a signed Nostr event for the **agent** key; clients may need a refresh.
- Prefer uploading to **your** relay Blossom so avatars stay on your domain.
- Do **not** put human Desktop or relay signing secrets into these commands.

## Related

- Always-on ACP agents: `references/buzz-acp-bridge.md`
- Identity separation: `references/hermes-gateway.md`
- Mobile pairing: `references/mobile-pairing.md`
