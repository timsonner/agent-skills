# Windows pattern: import skills from GitHub without cloning

Use when Windows Defender/policy blocks `git clone` or archive extraction but raw HTTPS is permitted.

## Procedure
1. Enumerate repo files via GitHub tree API (`/git/trees/<branch>?recursive=1`).
2. Filter to `SKILL.md` files in desired subtree.
3. Download each file from `raw.githubusercontent.com`.
4. Write into `C:/Users/<user>/AppData/Local/hermes/skills/imported/<source>/...` preserving folder structure.
5. Verify with both disk count and Hermes registry visibility.

## Why this matters
- Avoids cloning while still learning full skill content.
- Works well on Windows hosts where Defender blocks some repo operations.

## Re-import rule
After adding Defender exclusion or restoring quarantined files, re-run the import to guarantee full set integrity.