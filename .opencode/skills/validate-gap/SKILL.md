---
name: validate-gap
description: Validate a suspected bug in Omarchy before treating it as a gap — reproduce it, rule out this repo's own overrides, decide whether it is an upstream bug or local config, then search the Omarchy repositories for an existing issue or PR. Use whenever the user says something looks wrong, broken, missing, or asks whether it is an Omarchy bug, should be reported, or belongs in KNOWN-GAPS.md. Triggers include "this looks wrong", "is this an Omarchy bug", "validate this gap", "should I report this", and "is there an issue for this". Not for re-checking existing register entries or removing workarounds — use gap-watch for that.
---

# Validate Gap

Only real upstream gaps belong in `KNOWN-GAPS.md`. A matching GitHub issue is
not proof that the symptom here is the same bug, and a strange behaviour is not
an upstream bug until this repo's own overrides are ruled out. Validate first,
search second.

## 1. Scope the symptom

First check `KNOWN-GAPS.md`: if a row already covers the symptom, the job is to
confirm or update it, not to add a second one.

Pin down what happens versus what should happen, the steps, whether it repeats,
and when it started (a recent Omarchy update is a strong clue). Note the
hardware when it matters (laptop model, GPU, audio codec, display connection).
Ask only for details that could change the verdict; otherwise proceed with what
you have.

## 2. Rule out this repo

Read the relevant files before testing:

- Hyprland overrides: `config/hypr/.config/hypr/{input,looknfeel,bindings,monitors}.lua`.
- Audio: the `omarchy-headset-mic` helper in the `wireplumber` package, and the
  headset section in `README.md`.
- App config: `config/spotify`, `config/herdr`, `config/kitty`,
  `config/starship.toml`, `zsh/`.
- Stow: `~/.config/<app>` is often a symlink into this repo, so an override may
  be what the user is seeing even if the value looks like a default.
- Theme: `config/omarchy-themes/.../ayu-dark` changes colours and backgrounds.

Read the installed default first: what would Omarchy do without this repo?
Compare against `/usr/share/omarchy/default` and `/usr/share/omarchy/config`,
and ask the running system (`hyprctl getoption`, `pactl list cards`, …). Check
the installed package, channel and related versions (`pacman -Q omarchy
hyprland pipewire wireplumber`, kernel, `omarchy-channel-current`). If the
symptom disappears once the override is removed, it is local config, not a gap
— propose the fix here.

Do not change configs during validation without asking, and restore anything
you toggle.

## 3. Reproduce and collect evidence

- Get a minimal reproduction and repeat it when safe.
- Logs and state: `journalctl -b`, `journalctl --user -u <unit>`,
  `hyprctl monitors`/`getoption`, `wpctl status`, `pactl list`, `aplay -l`,
  `lspci -nnk`, and the relevant `/sys` or app log.
- Timeline: `/var/log/pacman.log` shows when Omarchy and kernel packages last
  changed.
- Avoid destructive tests. If a test needs a config change or a package
  downgrade, ask first and make it reversible.

## 4. Decide the verdict

| Verdict | Test |
| --- | --- |
| Local config | Symptom tracks an override in this repo |
| Expected behaviour | Matches Omarchy's documented or shipped default |
| Hardware / driver / kernel | Reproduces with stock config; device or driver implicated |
| Upstream bug | Omarchy's default behaviour is wrong, independent of our config |
| Documented, not reproducible now | Device absent, intermittent, or needs hardware; prior logs plus a matching upstream mechanism |
| Unclear | Evidence missing; say exactly what to collect next |

Hardware and kernel problems can still be Omarchy bugs if the distro kernel or
packaging is implicated. Otherwise name the driver or kernel tracker. For the
documented-but-not-reproducible case, record it as `accepted` and name what is
unverified; do not claim it was confirmed live.

## 5. Search the Omarchy repos

From the repo root:

```bash
.opencode/skills/validate-gap/scripts/search-upstream.sh <search terms>
.opencode/skills/validate-gap/scripts/search-upstream.sh --state closed <terms>
```

Try two or three query shapes: the visible symptom, the component, and any
exact error text. Fix PRs often use mechanism vocabulary instead of the user's
words ("inactive card outputs", "multi-port sink"), so if the symptom words miss,
search the terms the code and logs use, read the links inside related threads,
and check the relevant labels (`gh search issues --repo omacom/omarchy --label
audio --state open`). Use `--state closed` for history, and search
`omacom/omarchy-pkgs` (`REPO=…`) when the problem is install or update related.
A non-zero exit from the script means the search failed, not that nothing
matched.

For each plausible hit, read the thread rather than the title: state, milestone,
merged fix, workaround, duplicate or won't-fix close. For a merged PR, compare
its merge commit with the installed tag (`gh api repos/omacom/omarchy/compare/
<sha>...<tag>`): `ahead` or `identical` means the fix is in that tag, while
`behind` or `diverged` means it is not (a merged date alone proves nothing).
If an open issue or PR already covers it, link it; do not file a duplicate. If
nothing matches, draft an issue with title, system details, steps,
expected/actual and logs — but ask before filing anything upstream.

## 6. Record the outcome

- Check for an existing row first; update it instead of adding a duplicate.
- Real upstream bug that changes what we do here → add or update a row in
  `KNOWN-GAPS.md` with its local state (`patched`, `accepted`, `override`),
  upstream refs, and the condition that closes it.
- Fix already in the installed stable release → no row; say so.
- Existing open issue/PR and we are waiting → `accepted`, unless we keep a
  workaround, then `patched`.
- Caused by this repo → fix it here with a minimal diff, or record it as an
  `override` only if it is deliberate.
- Expected behaviour → no row; explain why.
- Do not add a row for an upstream bug that does not change what we do here.

## Report

```
Verdict: <local config | expected | hardware/driver | upstream bug | documented, not reproducible | unclear>
Installed default: <what Omarchy does without this repo>
Evidence: <2-4 bullets with the commands or log lines that decided it>
Upstream: <#refs and state, and whether the fix is in the installed tag>
Register: <existing row? updated/added/none, with the row text>
Next: <fix here | wait for stable | file issue | need more evidence>
```

## Rules

- Validate before searching. An issue title that matches the words is not proof
  the mechanism is the same.
- "Cannot reproduce right now" is not "not a bug". Use prior logs and matching
  mechanisms, and say plainly what is unverified.
- A failed search is not "no matching issue"; fix the query or the repo first.
- The installed version and channel decide "fixed", not the latest release.
- Do not file upstream issues, change configs, or commit without explicit
  confirmation.
- Keep the repo's minimal-diff rule when fixing a local cause.
