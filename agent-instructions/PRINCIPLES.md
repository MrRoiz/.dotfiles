# Engineering principles

The rules here and in `ORGANIZATION.md`, `MODULARITY.md`, `CONFIGURATION.md`,
`CHANGES.md` and `NOTIFY.md` apply to every change. A project's own instructions
(`AGENTS.md`, `CLAUDE.md`) win where they disagree; when that happens, say
which rule you followed and why.

- **YAGNI:** Add only what the current task needs. Do not build speculative
  abstractions, options, extension points, or compatibility layers.
- **KISS:** Prefer the simplest solution that works. Avoid unnecessary layers,
  indirection, cleverness, and premature optimization.
- **Readability first:** Optimize for the next reader. Clear names, small
  focused units, explicit control flow, and obvious data flow matter more than
  brevity or clever tricks. Fewer lines is not the goal; code a reader gets in
  one pass is, and more lines are fine when they buy that readability, as long
  as the other rules still hold. Prefer a little duplication over a premature
  abstraction.
  - One step per line: give an intermediate result a name instead of nesting
    calls, chaining long expressions or packing logic into one line.
  - Spell out logic: a plain loop over a dense one-line transformation, and a
    full conditional over a compressed inline one when it holds real logic.
  - Leave a blank line between the steps of a function (gather, decide, act,
    return) and between groups of related lines. Label any group whose purpose
    isn't obvious with a short comment above it, not only constants.
  - Split a long call or literal one argument or field per line, and name the
    arguments when a call takes several values of the same kind.
  - Return early instead of nesting; keep each branch short enough to see whole.
  - Comment the hacks, not the obvious: only add a comment when code is
    genuinely tricky or works around a real limitation, and say why it is
    there and, for a workaround, what would let it go. Do not restate what the
    code already says.
