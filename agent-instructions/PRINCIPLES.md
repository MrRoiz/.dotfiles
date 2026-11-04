# Engineering principles

- **YAGNI:** Add only what the current task needs. Do not build speculative
  abstractions, options, extension points, or compatibility layers.
- **KISS:** Prefer the simplest solution that works. Avoid unnecessary layers,
  indirection, cleverness, and premature optimization.
- **Readability first:** Optimize for the next reader. Clear names, small
  focused units, explicit control flow, and obvious data flow matter more than
  brevity or clever tricks. Prefer a little duplication over a premature
  abstraction.
- **Review-friendly:** Make the smallest diff that solves the task. Avoid
  unrelated edits, reformatting, renames, and refactors in the same change;
  keep behavior changes and cleanup separate so the review stays focused.
- Improve the code you are already changing, but do not rewrite unrelated code
  just to make it prettier; keep diffs focused.
- Follow the surrounding project's style and conventions. When in doubt, choose
  the smaller, more obvious change.
