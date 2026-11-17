---
name: gap-watch
description: Re-check KNOWN-GAPS.md against upstream Omarchy and retire a local patch, port or override once its fix ships in the installed stable release. Use when asked to check gaps or upstream status, whether a PR is in stable, whether a workaround can go, or after an Omarchy update. Not for new symptoms — use validate-gap.
---

# Gap Watch

`KNOWN-GAPS.md` is the register. Each row has a local state — `patched`
(workaround), `port` (backported upstream change), `override` (deliberate
local setting) or `accepted` (no local code) — its upstream refs and a "Closes
when" condition; each entry's section lists its "Removal" and sometimes
"Validate removal" steps. Retire a local piece only when the fix is in the
installed stable release and works on this machine: a version number is not
proof, and stable can regress.

1. Run `.agents/skills/gap-watch/scripts/gap-status.sh` (it finds the register
   through git; `REPO` and `GAPS_FILE` override the defaults). It prints the
   installed package, channel and tag, the latest stable and prerelease tags,
   and every cited `#ref` with its state and, for a merged PR, whether it is in
   each of those tags.
2. Judge each row by its "Closes when" text, not by "merged". A fix only in a
   prerelease, or merged without a release, is not closed for a stable install;
   if the channel is `rc` or `dev`, say so.
3. Report a table — gap, local state, upstream status, action (`none`,
   `wait for stable`, `verify then remove`) — naming the installed version.
4. For a closed `patched`, `port` or `override` row:
   - Verify the stock behaviour live first, as the entry describes; say when
     missing hardware limits the check.
   - Read the files "Removal" names (they may have gained neighbouring
     settings), show the exact lines, and ask before changing anything. For an
     override, remove only that setting, not the block it shares.
   - Follow "Removal" in order — disable a shipped service before deleting its
     files — then restow the package (`restow <pkg>`), reload the app if it
     does not watch its config (e.g. `hyprctl reload`), and run "Validate
     removal" or re-verify. If the stock default still falls short, restore
     the piece and leave the row open.
   - Treat "Removal" as a starting point: grep the repo for the identifiers the
     entry introduced (command, state flag, unit, path), delete the leftovers
     the fix makes redundant, and say what you removed. Touch nothing else.
   - Delete the row and its section, and update every `README.md`/`AGENTS.md`
     reference it lists, including install bullets and anchors.
5. For a closed `accepted` row, delete the row and its notes. Never add a
   workaround just because a gap is open.

## Rules

- A ref closed without a merged fix (duplicate, won't fix): update the row's
  upstream ref instead of removing the local piece.
- Add any new gap found while working, with its upstream ref and closing
  condition.
- Checks are read-only; any machine change follows "Change boundaries" in
  `AGENTS.md`. Don't commit or push unless asked.
