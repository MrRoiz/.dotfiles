# Changes

- **Smallest diff that solves the task.** No unrelated edits, reformatting,
  renames or refactors; behaviour changes and cleanup go in separate changes.
  Improve the lines you touch; leave the rest.
- **Deprecate rather than bloat.** Delete the dead code your change leaves when
  that stays within the lines you touch. If it reaches far beyond them, mark it
  deprecated (the language's marker, e.g. `@deprecated`, plus why and what
  replaces it) and propose the removal separately — unless the task is that
  removal or the developer asks for it.
- **Verify with the project's tools** once the change is complete, before
  committing: its formatter, linter and tests, scoped to what you touched, with
  capped parallelism (`pytest -n 2`, `jest --maxWorkers=2`, `make -j2`). Run
  the full suite at full speed only for a wide change or on request. Add or
  update tests for new logic when a suite exists. Report failures; never hide
  them.
- **Self-review before calling it done.** Check your diff against every rule in
  these files; fix what breaks one or say why it stays. Mention problems in
  code you did not touch; don't fix them.
