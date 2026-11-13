# Engineering principles

The rules here and in `ORGANIZATION.md`, `MODULARITY.md`, `CONFIGURATION.md`,
`CHANGES.md`, `GIT.md` and `NOTIFY.md` apply to every change. A project's own
instructions (`AGENTS.md`, `CLAUDE.md`) win where they disagree; when that
happens, say which rule you followed and why.

**Agents write the code; humans review and maintain it.** Every rule here
serves that reader: someone who did not write the code must be able to open
any file, find their bearings quickly (where am I, what does this do, where
does it go next), and change it with confidence. When a choice is close, pick
the one that is easier for a human to read and navigate.

- **YAGNI:** Add only what the current task needs. Do not build speculative
  abstractions, options, extension points, or compatibility layers.
- **KISS:** Prefer the simplest solution that works. Avoid unnecessary layers,
  indirection, cleverness, and premature optimization.
- **DRY:** Give each piece of knowledge — a rule, formula, behaviour, value or
  decision — exactly one home, and reuse it from there. Copies drift: change one
  and the others quietly go stale. Reuse the existing unit instead of copying
  it; when the same knowledge shows up a second time, extract it into the module
  that owns its domain (see `ORGANIZATION.md` and `CONFIGURATION.md`).
  - Look for the real duplication first: prefer a little duplication over a
    premature abstraction when the shared shape is only incidental (see "No
    premature abstraction" in `MODULARITY.md`).
- **Readability first:** Optimize for the next reader. Clear names, small
  focused units, explicit control flow, and obvious data flow matter more than
  brevity or clever tricks. Fewer lines is not the goal; code a reader gets in
  one pass is, and more lines are fine when they buy that readability, as long
  as the other rules still hold.
  - Names say what, not how: functions are verbs (`load_config`), booleans
    read as a question (`is_ready`, `has_items`), and a value with a unit
    carries it (`timeout_ms`). Spell words out except for well-known
    abbreviations, and make a name more descriptive the wider its scope.
  - Name a compound condition: put it in a well-named boolean or helper
    instead of an `if` with several `and`/`or`s, and state conditions
    positively (`if is_valid`, not `if not is_invalid`).
  - One step per line: give an intermediate result a name instead of nesting
    calls, chaining long expressions or packing logic into one line.
  - Spell out logic: a plain loop over a dense one-line transformation, and a
    full conditional over a compressed inline one when it holds real logic.
  - Leave a blank line between the steps of a function (gather, decide, act,
    return) and between groups of related lines. Label any group whose purpose
    isn't obvious with a short comment above it, not only constants.
  - Split a long call or literal one argument or field per line.
  - Return early instead of nesting; keep each branch short enough to see whole.
  - Comment the hacks, not the obvious: only add a comment when code is
    genuinely tricky or works around a real limitation, and say why it is
    there and, for a workaround, what would let it go. Do not restate what the
    code already says.
- **Fail loudly:** Do not swallow errors. Catch an error only where you can
  handle it or add context, and make the message say what failed and with
  which input. Validate input at trust boundaries (user input, files, network)
  and trust it inside the code.
- **Delete dead code:** No commented-out code, unused parameters, imports or
  variables, and no leftover debug output. Removing a feature also removes what
  it pulled in: drop the library or package from the manifest, refresh the
  lockfile, and delete the config, scripts and assets that served only that
  feature. Git keeps the history. When the removal would swell the diff far
  beyond the task, follow the deprecation rule in `CHANGES.md` instead.
