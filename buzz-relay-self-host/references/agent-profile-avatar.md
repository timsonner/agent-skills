# Agent profile + avatar (Buzz)

Set display name, bio, and avatar for the **gateway agent identity** (the key in `BUZZ_PRIVATE_KEY`). Placeholders only — never commit private keys or live media URLs into shared skills.

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

### Avatar (Blossom upload → profile URL)

`--avatar` wants a **URL** (not a bare local path). Upload to the relay media store first:

```bash
# Example asset often present on Hermes installs:
#   /usr/local/lib/hermes-agent/website/static/img/nous-logo.png
# Or any PNG/JPEG/WebP you choose.

buzz upload file --file /path/to/avatar.png
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
  buzz upload file --file /path/to/avatar.png \
    | python3 -c 'import sys,json; print(json.load(sys.stdin)["url"])'
)"
buzz users set-profile --name Hermes --about 'Hermes Agent' --avatar "$AVATAR_URL"
```

## Notes

- Profile is a signed Nostr event for the **agent** key; clients may need a refresh to show the new picture.
- Prefer uploading to **your** relay Blossom (`https://<buzz-fqdn>/media/…`) so avatars keep working offline from third-party CDNs.
- Do **not** put human Desktop or relay signing secrets into these commands.
- Optional: `scripts/set-agent-avatar.sh /path/to/image.png`

## Related

- Identity separation: `references/hermes-gateway.md`
- Mobile pairing is separate (Desktop QR): `references/mobile-pairing.md`
