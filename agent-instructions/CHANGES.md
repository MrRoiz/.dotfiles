# Changes

Keep each change small, focused, and easy to review.

- **Review-friendly:** Make the smallest diff that solves the task. Avoid
  unrelated edits, reformatting, renames, and refactors in the same change;
  keep behavior changes and cleanup separate so the review stays focused.
- Improve the code you are already changing, but do not rewrite unrelated code
  just to make it prettier; keep diffs focused.
- **Check before you call it done.** Go through what you changed (your diff,
  nothing else) against each rule in these files, not only the one you were
  asked about, and fix what doesn't follow them or say why it stays. Code you
  didn't touch is out of scope: mention a problem you see there, don't fix it.
