# Engineering principles

These files apply to every change. A project's own instructions (`AGENTS.md`,
`CLAUDE.md`) win where they disagree; say which rule you followed and why.

**Agents write the code; humans review and maintain it.** A reader who did not
write a file must quickly see where they are, what it does and where it goes
next, and change it with confidence. When a choice is close, pick the one that
is easier to read and navigate.

- **YAGNI:** Build only what the task needs — no speculative options,
  extension points, compatibility layers, empty layers or "framework" folders.
  Add an interface, base class or generic when a second real caller needs it;
  structure follows real duplication and growth.
- **KISS:** The simplest solution that works; no needless layers, indirection,
  cleverness or premature optimization.
- **DRY:** Each piece of knowledge — rule, formula, behaviour, value, decision —
  has one home and is reused from there, never copied; copies drift. When it
  appears a second time, extract it into the module that owns its domain. An
  incidentally shared shape is not duplication: a little repetition beats a
  premature abstraction.
- **SOLID, proportionately,** where the language and task allow. In existing
  code, follow its conventions and apply SOLID to what the change touches
  without twisting a working design; new code applies all five from the start.
  - **Single responsibility:** one job, one reason to change. If its one-line
    description needs "and", split it.
  - **Open/closed:** extend by adding code, not by branching a working unit;
    build the seam when the second real case exists.
  - **Liskov substitution:** a substitute honours the whole contract — inputs,
    outputs, errors, side effects. Needing exceptions means the abstraction is
    wrong.
  - **Interface segregation:** give each consumer the small interface it uses,
    not one wide shared one.
  - **Dependency inversion:** depend on abstractions, not concretions; the
    higher-level code owns the interface and lower-level code implements it.
- **Readability first:** code a reader gets in one pass beats fewer lines.
  - Names say what, not how: verbs for functions (`load_config`), questions for
    booleans (`is_ready`), units in values (`timeout_ms`). Spell words out
    except well-known abbreviations; the wider the scope, the more descriptive.
  - Name compound conditions (a boolean or helper) and state them positively
    (`if is_valid`, not `if not is_invalid`).
  - One step per line: name intermediate results instead of nesting calls or
    chaining; prefer a plain loop or full conditional to a dense one-liner.
  - Blank lines between a function's steps (gather, decide, act, return) and
    between groups of lines; a short comment labels any group whose purpose
    isn't obvious.
  - Long calls and literals: one argument or field per line.
  - Return early instead of nesting; keep each branch short enough to see whole.
  - Comment only tricky code, workarounds and a file's design pattern
    (`PATTERNS.md`): say why and, for a workaround,
    what would let it go. Never restate the code.
- **Fail loudly:** Never swallow errors. Catch only to handle one or add
  context, and say what failed with which input. Validate at trust boundaries
  (user input, files, network) and trust data inside.
- **Delete dead code:** no commented-out code, unused parameters, imports or
  variables, or debug output; git keeps the history. Removing a feature also
  removes its dependency (manifest and lockfile) and the config, scripts and
  assets only it used. If that would swell the diff far beyond the task,
  deprecate instead (`CHANGES.md`).
