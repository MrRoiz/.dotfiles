# Known gaps

Places where Omarchy and this setup disagree: gaps we patch locally, gaps we
accept, and local overrides that upstream may make unnecessary. Every entry
names the upstream change that closes it and what to do here once that change
ships.

Tracked upstream is **Omarchy only**. Workarounds for other upstreams
(Spotify's WebKit flags, herdr's fixed theme colours) live in `AGENTS.md`.

Snapshot 2026-11-05: installed `omarchy 4.5.0-3` (stable), latest stable
`v4.5.0`, latest prerelease `v4.5.0-rc3`.

| Gap | Local state | Upstream | Closes when |
| --- | --- | --- | --- |
| Headset microphone port | **patched** — `omarchy-headset-mic` service | #16529 (issue), #16633 (PR); #12489, #13758, #13775, #18725 are adjacent | Audio panel lists source ports as rows and keeps the headset port across replugs |
| HDMI/DP audio output | **patched** — combined analog+HDMI ACP profile (`alsa-card-profile` package) | #8789 (issue), #8820 (PR) | #8820 or equivalent ships in a stable release |
| Per-monitor workspaces | **port** — #16213 toggle in Lua + CLI + menu; bar half not ported | #16213 (open) | Stable ships the per-monitor workspace toggle |
| Screen-share cursor | **patched** — `cursor_mode = 2` in the `hypr` package's `xdph.conf` | #15577 (issue), #15580 (PR); #15690 closed in favour of #15580 | Stable ships `cursor_mode = 2` as the default and a browser share shows the pointer |
| FocalTech fingerprint reader | **accepted** — no local code; fingerprint setup unavailable | #11384 (issue), #11387 (PR); #14089, #8800, #16228 are adjacent | Stable's `omarchy-hw-fingerprint` detects `2808:a99a` and `omarchy setup security fingerprint` enrolls it |
| Weather bar widget hidden | **accepted** — no local code; widget missing while a location is saved | #19820 (issue), #19133 (fix on `quattro`), #19357 (backport PR); #17404, #20035, #19348 are adjacent | Stable sends a User-Agent to Open-Meteo and the weather pill shows with a saved location |

Re-check with the `gap-watch` skill or
`.agents/skills/gap-watch/scripts/gap-status.sh`; do not remove a local piece
on a version number alone — verify the behaviour on this machine first.

## Headset microphone port

The ALC256 exposes the internal mic and the headset mic as two ports of one
source. Omarchy's audio panel lists devices, not ports, so the headset mic has
no row to click, and WirePlumber falls back to the internal mic after a replug.

- Local patch: `config/wireplumber/.local/bin/omarchy-headset-mic` plus its
  user service. Installed by `setup_headset_mic` in `scripts/omarchy.sh`, and
  documented under "Headset microphone" in `README.md`.
- Upstream: #16529 tracks selecting input ports of one source; #16633 (open)
  is the fix: it lists source ports as rows and switches the port before
  setting the default, but its description says jack persistence across
  replugs is still untested. #12489 expands sink ports only, and #13758 asks
  to filter unplugged inputs; #13775 was closed, and #18725 (open) now does
  that filtering without adding port selection. #10985 implemented both sides
  but was closed as a duplicate of #7205, which only covered sinks.
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

The Intel HDA card exposes analog and HDMI as mutually exclusive profiles, so
activating one drops the other's sink. The panel lists live sinks only and has
no card-profile path (Quickshell 0.3.2 exposes nodes but no card or profile
type), and WirePlumber does not switch the profile (its ALSA monitor sets
`api.acp.auto-profile = false`; analog also outranks HDMI), so an attached
display has no HDMI sink to select.

- Local patch: `config/alsa-card-profile` provides the profile set ACP reads
  before `/usr/share` (`~/.config/alsa-card-profile/mixer/profile-sets/default.conf`).
  It re-includes the packaged set unchanged and adds one combined profile,
  `output:analog-stereo+output:hdmi-stereo+input:analog-stereo` (priority 7000),
  so both sinks exist at once and the stock panel lists both the display and
  the analog output. `setup_hdmi_audio` in `scripts/omarchy.sh` stows it,
  restarts WirePlumber (ACP reads the set when the card is created) and selects
  the combined profile once, because WirePlumber restores the stored analog
  profile over the higher-priority combined one. That selection is stored, so
  later boots restore it — confirmed live 2026-11-16: both sinks appear
  ("Built-in Audio Analog Stereo" and "... Digital Stereo (HDMI) [SAMSUNG]")
  and the combined profile comes back across a WirePlumber restart.
  Unplug/replug behaviour is still unverified; by its code the panel hides an
  output whose ports are all unavailable (`omarchy-audio-sink-availability`),
  so the HDMI row should vanish while no display is attached.
- Limits: the combined profile maps only the first HDMI PCM (`hdmi-output-0`,
  `aplay -l` device 3). A display on HDMI 1–3 (e.g. USB-C/DP) still needs
  `pactl set-card-profile <card> output:hdmi-stereo-extraN+input:analog-stereo`.
  The `.include` uses the packaged absolute path; ACP skips a missing include
  silently, so if PipeWire ever moves `/usr/share/alsa-card-profile`, the set
  would hold only this profile with undefined mappings and the card would
  likely fail to load (not tested; the path has been stable for years).
- Upstream: #8789 is the open enhancement; #8820 is the open fix and adds two
  `pactl`/`jq` helpers plus picker rows for inactive card outputs (Quickshell
  has no profile API, so the panel has to shell out). #14080 was closed as a
  duplicate of #8789, #14082 as a duplicate of #8820, and #10938 was closed
  unmerged.
- Closes when: a stable release's audio panel lists inactive card outputs,
  selecting one activates the profile, creates the sink, and moves streams.
- Removal: `cd ~/.dotfiles/config && stow --delete -t "$HOME"
  alsa-card-profile`, then `systemctl --user restart wireplumber` (the stored
  profile name disappears with the set, and WirePlumber falls back to analog;
  `pactl set-card-profile <card> output:analog-stereo+input:analog-stereo` makes
  it explicit). Delete the `alsa-card-profile` stow package, the
  `setup_hdmi_audio` function, its call and the header step in
  `scripts/omarchy.sh`, the `restow` package-list entry, the README section and
  its installer/Layout mentions, the `AGENTS.md` restow mention, and this row
  and section.
- Validate removal: `pactl list cards` must no longer offer
  `output:analog-stereo+output:hdmi-stereo+input:analog-stereo`, and
  `~/.local/state/wireplumber/default-profile` must not name it — run
  `pactl set-card-profile <card> output:analog-stereo+input:analog-stereo` once
  if it does, or pick any profile in the panel, which rewrites the entry.
  `~/.local/state/wireplumber/default-routes` keeps a
  `<card>:profile:output:analog-stereo+output:hdmi-stereo+input:analog-stereo`
  routes entry that no command rewrites; it is runtime state, not a workaround,
  and WirePlumber ignores routes for a profile that no longer exists. Then
  `grep -rn "alsa-card-profile\|alsa_card_profile\|hdmi_audio\|hdmi-audio\|analog + HDMI\|analog-stereo+output:hdmi-stereo" ~/.dotfiles`
  must return nothing: no leftover command, profile name, package, `restow`
  entry, installer function, call or header step, README link or doc line.
  (While this section still exists it matches itself, so run the grep after
  deleting it.)
  Verified live 2026-11-16: `stow --delete` plus a WirePlumber restart drops
  the profile and lands back on `output:analog-stereo+input:analog-stereo`
  with no other command; the dangling state entry is ignored, and restowing
  restores both sinks.

## Per-monitor workspaces

Omarchy 4.5 gives every monitor workspaces 1-10 of its own and renumbers
workspaces into those blocks whenever monitors change. The release has no
switch for it, so `Super + 1` means "the focused monitor's first workspace"
rather than global workspace 1.

- Local port: `config/hypr/.config/default/hypr/monitor-workspaces.lua` shadows
  the packaged module (bootstrap puts `~/.config/?.lua` ahead of
  `$OMARCHY_PATH/?.lua`). With
  `~/.local/state/omarchy/toggles/no-monitor-workspaces` absent it loads the
  packaged module unchanged; with the flag present it restores global ids and
  removes the block map so the stock bar falls back to global numbering.
  Disabling renames workspaces still on per-monitor ids into their global slot
  (12 becomes 2), so the bar label and `Super + 2` agree; turning it back on
  resumes reconciliation, which may renumber workspaces into their monitor
  blocks.
- Toggle: `config/bin/.local/bin/omarchy-toggle-monitor-workspaces [on|off]`,
  or _Setup → Workspaces → Per Monitor Workspaces_ in the menu. The `omarchy`
  dispatcher only scans its packaged bin directory, so `omarchy toggle
  monitor-workspaces` does not route until upstream ships the command; call the
  binary directly or use the menu.
- Not ported: the PR's `Workspaces.qml` global mode. In global mode the stock
  bar labels by monitor block, so ids above 10 show their local slot (12 appears
  as 2). The toggle avoids that by renumbering at disable time only, so a
  workspace created above 10 afterwards mislabels again: keep global workspaces
  in 1-10. The PR's second commit, "Keep actual workspace 10 labels in global
  mode", only corrects the id-10 row, so cloning that widget would not lift the
  limit on its own.
- Upstream: #16213 adds the toggle and bar mode, last updated 2026-11-04 with
  that label fix and two-monitor feedback on `v4.5.0-rc3` confirming the
  disabled path (global ids, no reconcile). It keeps existing ids when
  disabling, so the renumber step here is a local addition (#12978 and #7615 are
  the wider global-mode requests; both open).
- Closes when: a stable release ships the toggle and both modes in the stock
  bar, verified on this machine.
- Removal: delete the override module, the toggle command, and the two
  `setup.workspaces*` menu entries; drop this row and section; then
  `restow hypr bin omarchy-menu`, `omarchy menu refresh`, and `hyprctl reload`.
  The renumber-on-disable step is local and goes with the command; upstream
  keeps ids because its bar widget labels them truthfully, so do not port that
  step into the packaged command. Before relying on the packaged command, move
  any workspace still above 10 into 1-10 (upstream keeps ids), then `restow bin`
  so the old copy is gone.

## Screen-share cursor

Omarchy's `xdph.conf` leaves `screencopy:cursor_mode` unset, so
xdg-desktop-portal-hyprland keeps its default (hidden). Browsers and Electron
apps ask for a metadata cursor, which the portal does not advertise
(`AvailableCursorModes` is hidden|embedded), so they send no mode at all and
viewers never see the pointer.

- Local patch: `config/hypr/.config/hypr/xdph.conf` mirrors the shipped default
  and adds `cursor_mode = 2`; `stow_hypr_overrides` and `restow` remove the
  live file before stowing.
- Upstream: #15577 (open, `bug`) reports it; the fix is
  [#15580](https://github.com/omacom/omarchy/pull/15580) (open), which sets the
  same default plus a migration; #15690 was closed in favour of #15580. xdph
  1.4.1 added the option (hyprwm/xdg-desktop-portal-hyprland#373).
- Closes when: a stable release ships `cursor_mode = 2` as the default (#15580
  merged) and a browser share shows the pointer, verified on this machine.
- Removal: delete the repo `xdph.conf` and its two `rm -f` entries; then
  `rm ~/.config/hypr/xdph.conf` (the stow symlink) and
  `omarchy refresh config hypr/xdph.conf` to restore the shipped default as a
  real file (refresh uses `cp -f`, so the symlink must go first). Restart the
  portal and drop this row and section.
- Caveat: remote-desktop captures on Intel iGPUs can still hide the pointer for
  a different reason (#16622; `cursor:no_hardware_cursors = 1` fixes that one),
  so the cursor mode alone does not cover that path.

## FocalTech fingerprint reader

The laptop (ASUS Vivobook X1605VA) has a FocalTech FT9349 ESS match-on-chip
reader, USB `2808:a99a`, with no kernel driver bound — the shape of a
libusb reader. `omarchy-hw-fingerprint` exits 1 for it: `2808` is not in
`fingerprint_vendors`, and the product string matches none of its name
patterns. So `omarchy setup security fingerprint` stops with "No fingerprint
sensor detected" before installing `fprintd`/`libfprint-git`, and the
post-update invitation never appears. The driver is not the gap: the
`libfprint-git` Omarchy pins (`1.94.100.r10.g6f9479c`) lists `2808:a99a` in
`focaltech_moc`. Confirmed 2026-11-18.

- Local state: none. Installing `fprintd` and `libfprint-git` by hand would
  bypass the wizard's PAM setup, so we wait for the detector fix.
- Upstream: #11384 reports the false negative for `2808:*` readers; #11387
  (open, `verified`, `ready`) adds vendor `2808` to the detector while keeping
  the existing driver check, which rules out FocalTech touchpads (this
  laptop's `2808:0212` binds `i2c-hid`). #14089 (`2808:a97a`) and #8800
  (`2808:a658`) are other FocalTech readers; #16228 matches one
  vendor:product only; #11884 and #15586 were closed unmerged.
- Checked 2026-11-18: the PR's `omarchy-hw-fingerprint` (head `e550879`, the
  only change is adding `2808` to `fingerprint_vendors`) exits 0 against this
  laptop's sysfs through the vendor path (reader `1-7`, interface `1-7:1.0`
  driverless), while the installed one exits 1. Enrollment with this reader
  is unverified: it needs `fprintd`, `libfprint-git` and the wizard's PAM
  changes.
- Closes when: `omarchy-hw-fingerprint` exits 0 on this laptop in a stable
  release, and `omarchy setup security fingerprint` enrolls a finger that
  `sudo` accepts.
- Removal: drop this row and section.

## Weather bar widget hidden

With a location saved (`~/.local/state/omarchy/settings/weather.json`), the
`omarchy.weather` bar icon comes only from the Open-Meteo forecast request in
`shell/plugins/panels/weather/Panel.qml`. 4.5.0-3 sends it with curl's default
User-Agent, and Open-Meteo answers that full request with 403 Forbidden, so
the label stays empty and the widget hides itself. Confirmed 2026-11-24: the
widget's exact URL returns 403 three times out of three as `curl/8.23.0` and 200
as `Mozilla/5.0` or `omarchy`; smaller requests return 200 with the default
agent, and wttr.in and `omarchy-weather-status` work.

- Local state: none. `omarchy weather location --clear` would bring the pill
  back through IP auto-location and the wttr.in icon, at the cost of the saved
  location, so we keep the location and wait.
- Upstream: #19820 (open) is this bug. #19133 adds an identifying User-Agent
  to both Open-Meteo requests on `quattro` (`f12dc43`, `diverged` from
  `v4.5.0`); #19357 (open) backports it to 4.5, and #19198 (open) proposes the
  same plus a wttr.in fallback. #17404 tracks the missing fallback when
  Open-Meteo fails; #20035 and #19348 report the same symptom.
- Closes when: the installed stable `Panel.qml` passes `-A` to the Open-Meteo
  curl call, and the weather pill shows after a shell restart with the location
  still saved.
- Removal: drop this row and section.

## Adding a gap

Validate the symptom first with the `validate-gap` skill: confirm it is real,
rule out this repo's overrides, and check the Omarchy repos for an existing
issue or PR. Then add a row with its local state and the condition that closes
it.

## Closing a gap

1. Confirm the closing behaviour on this machine, not just the version.
2. Remove only what the entry names. Its "Removal" list is a starting point,
   not a limit: code, state flags, user services, CLI shims, menu rows and docs
   all count. Grep the repo for every identifier the entry introduced (command,
   flag, unit, path) and delete the leftovers the fix makes redundant; leave
   anything unrelated alone.
3. Update this table and any `README.md` / `AGENTS.md` references.
4. Re-stow the affected package (for example `restow hypr` after editing
   `input.lua`, or `restow bin` after editing `restow`).
5. Do not commit unless asked.
