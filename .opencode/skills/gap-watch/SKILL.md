---
name: gap-watch
description: Check the gaps tracked in KNOWN-GAPS.md and retire a local workaround or override once the matching upstream Omarchy fix ships in a stable release. Use when the user asks to check gaps or upstream status, whether a tracked issue or PR is fixed or in stable, whether a new Omarchy release lets us drop a configured workaround, or after an Omarchy update. Triggers include "check gaps", "gap watch", "check upstream", "is the HDMI profile PR in stable", "can we drop the headset workaround", and "Omarchy updated". Not for fixing a bug or validating a new symptom that is not in the register — use validate-gap for that.
---

# Gap Watch

`KNOWN-GAPS.md` at the repo root is the register. Each row names a gap, its
local state (`patched`, `accepted`, `override`), the upstream reference, and the
condition that closes it. This skill re-checks the references, compares them
with the installed stable Omarchy, and retires local pieces only when the fix is
actually present and works here.

## Workflow

1. Run the status helper from the repo root (the script locates the register
   through git, so the working directory only affects how you spell the path):

   ```bash
   .opencode/skills/gap-watch/scripts/gap-status.sh
   ```

   It prints the installed Omarchy package and channel, the latest stable and
   prerelease tags, and the state of every `#ref` cited in `KNOWN-GAPS.md`,
   including whether each merged PR is contained in those tags.

2. Read `KNOWN-GAPS.md`. For every row, judge the upstream state against the
   row's "Closes when" text, not against "the PR is merged" alone. A fix that is
   only in a prerelease or only in `quattro` without a release is not closed
   for a stable install.

3. Report a compact table: gap, local state, upstream status, action
   (`none`, `wait for stable`, `verify then remove`). Name the installed
   version you compared against.

4. For a `patched` row that is closed in the installed stable release:
   - Verify the behaviour live before editing. For the headset mic, open the
     audio panel and replug the combo jack, or inspect
     `pactl list sources` for the active port; the port may only exist while a
     headset is plugged in, so say when the hardware limits the check.
   - Read the files the entry's "Removal" section names before editing; the
     config may have gained neighbouring settings since the entry was written.
     Show the exact lines and ask for confirmation before changing them.
   - Disable and delete any user service the workaround ships before deleting
     its files (for the headset mic,
     `systemctl --user disable --now omarchy-headset-mic.service`, then
     `systemctl --user daemon-reload`).
   - After removal, re-stow the affected package (for example `restow hypr`
     after an `input.lua` edit, or `restow bin` after editing `restow`) and
     verify again.
   - Remove the row and its section from `KNOWN-GAPS.md`, then update every
     `README.md` or `AGENTS.md` reference the entry lists, including install
     bullets and anchors.

5. For an `override` row that is closed in the installed stable release:
   delete only the override entry named by the entry, not the whole shared
   block. For Caps Lock that is the `kb_options = ""` line and its comment in
   `input.lua`; keep the touchpad settings in the same block. Then `restow hypr`
   and `hyprctl reload`. Ask the user to confirm the keys behave as expected. If
   the default still differs, keep the override and leave the row open.

6. For an `accepted` row, never add a workaround just because the gap is open.
   When it closes in stable, remove the row and its manual notes; there is no
   code to delete.

## Rules

- Do not remove a workaround because a version number changed. Confirm the
  behaviour on this machine; a stable release can regress.
- Keep the diff to the files the entry names. This repo values minimal diffs;
  do not reformat or reorder unrelated lines.
- If you find a new gap while working — a workaround, an accepted limitation, or
  an override upstream may make unnecessary — add it to `KNOWN-GAPS.md` with its
  upstream ref and the condition that closes it.
- Do not commit or push unless the user asks.
- If a reference is closed without a merged fix (duplicate, won't fix), update
  the row's upstream reference instead of removing the local piece.
- If the installed channel is `rc` or `dev`, report it clearly; "closed" means
  closed for the stable channel the user runs.
