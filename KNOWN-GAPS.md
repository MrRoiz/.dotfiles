# Known gaps

Places where Omarchy and this setup disagree: gaps we patch locally, gaps we
accept, and local overrides that upstream may make unnecessary. Every entry
names the upstream change that closes it and what to do here once that change
ships.

Tracked upstream is **Omarchy only**. Workarounds for other upstreams
(Spotify's WebKit flags, herdr's fixed theme colours) live in `AGENTS.md`.

Snapshot 2026-10-24: installed `omarchy 4.0.6-1` (stable), latest stable
`v4.0.6`, latest prerelease `v4.5.0-rc1`.

| Gap | Local state | Upstream | Closes when |
| --- | --- | --- | --- |
| Headset microphone port | **patched** — `omarchy-headset-mic` service | no direct fix yet; #12489, #13758, #13775 are adjacent | Audio panel lists source ports as rows and keeps the headset port across replugs |
| HDMI/DP audio output | **accepted** — manual profile switch only, nothing in the dotfiles | #8789 (issue), #8820 (PR) | #8820 or equivalent ships in a stable release |
| Caps Lock / compose key | **override** — `kb_options = ""` in `input.lua` | #14939 | Installed stable includes #14939 and its default behaves as wanted |

Re-check with the `gap-watch` skill or
`.opencode/skills/gap-watch/scripts/gap-status.sh`; do not remove a local piece
on a version number alone — verify the behaviour on this machine first.

## Headset microphone port

The ALC256 exposes the internal mic and the headset mic as two ports of one
source. Omarchy's audio panel lists devices, not ports, so the headset mic has
no row to click, and WirePlumber falls back to the internal mic after a replug.

- Local patch: `config/wireplumber/.local/bin/omarchy-headset-mic` plus its
  user service. Installed by `setup_headset_mic` in `scripts/omarchy.sh`, and
  documented under "Headset microphone" in `README.md`.
- Upstream: #12489 lists sink ports as rows (outputs only); #13758 and #13775
  filter unplugged inputs. #10985 was closed unmerged. No issue or PR yet
  covers selecting input ports of one source.
- Closes when: the panel lists both ports of the single source, selecting the
  headset mic sticks, and a replug restores it without help.
- Removal: disable the service first
  (`systemctl --user disable --now omarchy-headset-mic.service`, then
  `systemctl --user daemon-reload`), delete the `wireplumber` stow package
  (helper script and unit), remove `setup_headset_mic`, its call, its comment,
  and the script header step from `scripts/omarchy.sh`, and remove every
  `wireplumber` entry from `restow`
  (the package list, the `want_wireplumber` variable and match, the `rm -f`
  block, and the service restart line). Then remove the README section and its
  installer and Layout mentions (including the `#headset-microphone` anchor),
  and the `restow` package list in `AGENTS.md`. Verify on the laptop that the
  panel switches ports and survives replugging.

## HDMI/DP audio output

The Intel HDA card exposes analog and HDMI as mutually exclusive profiles.
The panel lists live sinks only, and WirePlumber does not switch the profile
(its ALSA monitor sets `api.acp.auto-profile = false`; analog also outranks
HDMI), so an attached display has no HDMI sink to select.

- Local state: **accepted**. HDMI audio is not an everyday need, so there is no
  helper. When it is needed:
  `pactl set-card-profile alsa_card.pci-0000_00_1f.3 output:hdmi-stereo+input:analog-stereo`
  (and back with `output:analog-stereo+input:analog-stereo`).
- Upstream: #8789 is the open enhancement; #8820 is the open fix; #14080 was
  closed as a duplicate of #8789, #14082 as a duplicate of #8820, and #10938
  was closed unmerged.
- Closes when: a stable release's audio panel lists inactive card outputs,
  selecting one activates the profile, creates the sink, and moves streams.
- Removal: no local code to delete. Drop this row and the manual command once
  the panel handles it.

## Caps Lock / compose key

Omarchy 4.0 maps Caps Lock to Compose (`compose:caps`) and adds
`shift:both_capslock_cancel`, whose lone-Shift side effect clears Caps Lock.
`input.lua` overrides both by setting `kb_options = ""` to keep Caps Lock as
Caps Lock.

- Upstream: #14939 returns Caps Lock to normal and puts compose on
  Shift + Caps Lock. Merged 2026-10-11, shipped in `v4.5.0-rc1`; not in the
  installed `v4.0.6` yet.
- Closes when: the installed stable release includes #14939, Caps Lock still
  toggles on a single press, and Shift + Caps Lock composes.
- Removal: delete the Caps Lock comment and the `kb_options = ""` entry from
  the shared `hl.config` block in `config/hypr/.config/hypr/input.lua`; keep
  the touchpad `natural_scroll` override in that block. Then `restow hypr`
  (or `hyprctl reload`) and test both keys.

## Adding a gap

Validate the symptom first with the `validate-gap` skill: confirm it is real,
rule out this repo's overrides, and check the Omarchy repos for an existing
issue or PR. Then add a row with its local state and the condition that closes
it.

## Closing a gap

1. Confirm the closing behaviour on this machine, not just the version.
2. Remove only what the entry names; keep the diff to those files.
3. Update this table and any `README.md` / `AGENTS.md` references.
4. Re-stow the affected package (for example `restow hypr` after editing
   `input.lua`, or `restow bin` after editing `restow`).
5. Do not commit unless asked.
