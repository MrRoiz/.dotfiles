# Changes

Keep each change small, focused, and easy to review.

- **Review-friendly:** Make the smallest diff that solves the task. Avoid
  unrelated edits, reformatting, renames, and refactors in the same change;
  keep behavior changes and cleanup separate so the review stays focused.
  Improve the lines you already touch; leave the rest.
- **Deprecate rather than bloat the diff.** If the dead code a change leaves
  behind can be deleted within the lines you already touch, delete it. If the
  deletion would touch far more than the task requires, do not delete it in
  this diff:
  - Default: mark it deprecated — the language's marker (e.g. `@deprecated`)
    plus a note saying why it is dead and what replaces it — and propose the
    removal as its own change.
  - Delete it outright instead when the task is itself that removal or
    refactor, or when the developer asks for the whole removal at once.
- **Verify with the project's tools.** Run the project's existing formatter,
  linter and tests on what you changed once the change is complete, right
  before committing, not after every edit. Add or update a test for new logic
  when the project has a test suite. Report failures; do not hide them.
  Keep the run proportionate to the project and the machine: scope it to the
  files or tests you touched when the tool allows it, and cap parallelism
  (e.g. `pytest -n 2`, `jest --maxWorkers=2`, `make -j2`) instead of letting
  it take every core. Run the full suite at full speed only when the change
  is wide or the developer asks for it.
- **Check before you call it done.** Go through what you changed (your diff,
  nothing else) against each rule in these files, not only the one you were
  asked about, and fix what doesn't follow them or say why it stays. Code you
  didn't touch is out of scope: mention a problem you see there, don't fix it.
