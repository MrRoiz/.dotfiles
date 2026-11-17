---
name: validate-gap
description: Validate a suspected Omarchy bug before treating it as a gap — reproduce it, rule out this repo's overrides, decide upstream bug vs local config, and search Omarchy issues and PRs. Use when something looks wrong, broken or missing, or when asked whether it is an Omarchy bug, should be reported, has an issue, or belongs in KNOWN-GAPS.md. Not for existing register rows — use gap-watch.
---

# Validate Gap

Only real upstream gaps belong in `KNOWN-GAPS.md`. Validate first, search
second: a matching issue title is not the same mechanism, and odd behaviour is
not an upstream bug until this repo's overrides are ruled out. Validation is
read-only — config, runtime state, services, packages and hardware, including
harmless-looking toggles such as an audio card profile; any change follows
"Change boundaries" in `AGENTS.md`.

## 1. Scope the symptom

If a register row already covers it, confirm or update that row. Pin down
actual vs expected, the steps, whether it repeats, when it started (a recent
update is a strong clue) and, when it matters, the hardware (model, GPU, audio
codec, display link). Ask only for details that could change the verdict.

## 2. Rule out this repo

Read the overrides that touch the component before testing:

- Hyprland: `config/hypr/.config/hypr/` (`input`, `looknfeel`, `bindings`,
  `monitors` `.lua`, `xdph.conf`).
- Audio: the `wireplumber` (`omarchy-headset-mic`) and `alsa-card-profile`
  packages, and the headset section in `README.md`.
- Apps: `config/spotify`, `config/herdr`, `config/kitty`, `config/starship`,
  `zsh/`; colours and backgrounds: `config/omarchy-themes`.
- Patches already in `KNOWN-GAPS.md`. `~/.config/<app>` is often a symlink into
  this repo, so a value that looks like a default may be ours.

Then establish the stock behaviour: what Omarchy ships
(`/usr/share/omarchy/default`, `/usr/share/omarchy/config`), what the system
reports (`hyprctl getoption`, `pactl list cards`, …), and the versions
(`pacman -Q omarchy hyprland pipewire wireplumber`, `uname -r`,
`omarchy-channel-current`). If the symptom goes away without the override, it
is local config — propose the fix here.

## 3. Reproduce and collect evidence

Get a minimal reproduction and repeat it when safe; no destructive tests.
Sources: `journalctl -b`, `journalctl --user -u <unit>`, `hyprctl monitors`,
`wpctl status`, `pactl list`, `aplay -l`, `lspci -nnk`, `/sys` and app logs;
`/var/log/pacman.log` dates package changes.

## 4. Decide the verdict

| Verdict | Test |
| --- | --- |
| Local config | Symptom tracks an override in this repo |
| Expected behaviour | Matches Omarchy's documented or shipped default |
| Hardware / driver / kernel | Reproduces with stock config; device or driver implicated |
| Upstream bug | Omarchy's default behaviour is wrong, independent of our config |
| Documented, not reproducible now | Device absent, intermittent, or needs hardware; prior logs plus a matching upstream mechanism |
| Unclear | Evidence missing; say exactly what to collect next |

A hardware or kernel problem is still Omarchy's when its kernel or packaging is
implicated; otherwise name the driver or kernel tracker. "Cannot reproduce now"
is not "not a bug": record it as `accepted`, say what is unverified, and never
claim it was confirmed live.

## 5. Search upstream

```bash
.agents/skills/validate-gap/scripts/search-upstream.sh [--state open|closed] [--limit N] <terms>
```

It searches issues and PRs in `omacom/omarchy` (`REPO=omacom/omarchy-pkgs` for
install or update problems), open and closed unless `--state` narrows it. A
non-zero exit means the search failed, not that nothing matched — fix the
query or repo. Try two or three shapes: the symptom, the component, exact error
text. Fix PRs use mechanism words ("inactive card outputs", "multi-port
sink"), so also search the terms the code and logs use, follow links in
related threads, and check labels (`gh search issues --repo omacom/omarchy
--label audio`).

Read each plausible thread, not its title: state, milestone, merged fix,
workaround, duplicate or won't-fix close. The installed version and channel
decide "fixed", not a merge date: `gh api
repos/omacom/omarchy/compare/<merge-sha>...<installed-tag> --jq .status` gives
`ahead` or `identical` when the fix is in, `behind` or `diverged` when not.
Link an existing issue or PR rather than filing a duplicate. If nothing
matches, draft an issue (title, system details, steps, expected/actual, logs)
and ask before filing.

## 6. Record the outcome

- Upstream bug that changes what we do here → add or update a row with its
  local state, upstream refs and closing condition: `patched` if we keep a
  workaround, `port` for a backported fix, `accepted` while we just wait. One
  that changes nothing here gets no row.
- Fix already in the installed stable release → no row; say so.
- Caused by this repo → fix it here with a minimal diff, or add an `override`
  row only if the override is deliberate.
- Expected behaviour → no row; explain why.

## Report

```
Verdict: <local config | expected | hardware/driver | upstream bug | documented, not reproducible | unclear>
Installed default: <what Omarchy does without this repo>
Evidence: <2-4 bullets with the commands or log lines that decided it>
Upstream: <#refs and state, and whether the fix is in the installed tag>
Register: <existing row? updated/added/none, with the row text>
Next: <fix here | wait for stable | file issue | need more evidence>
```

Never file upstream, change config or commit without explicit confirmation.
