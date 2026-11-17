---
name: polish
description: Quality pass on the changed code — reuse, simplification, dead code and dependencies, efficiency, altitude — then apply the fixes; no bug hunting. Use when asked to polish, simplify, tidy or clean up the diff or recent changes, to review changes for quality, or after finishing a change. Not for correctness bugs or PR review.
---

# Polish

## 1. Scope and rules

Review the branch's changes plus the working tree
(`git diff $(git merge-base HEAD <default-branch>)`); on the default branch,
the uncommitted changes (`git diff HEAD`), or the last commit when there are
none. If the user named a PR, branch or path, review that instead. Leave code
outside the diff alone, except what the global instructions require removing
with it.

The global instructions (normally in context; if missing, say so rather than
guessing them) and the project's `AGENTS.md`/`CLAUDE.md`, including nested
ones for the changed directories, govern this review and override it. Project
rules add to the global ones, never replace them.

## 2. Review

With subagents, launch one per angle in a single message — a search agent for
reuse and dead code, a general one for altitude — each told to read the
governing instructions, which it starts without. The angles are independent.
Without subagents, cover every angle yourself in one pass.

Report each finding as `file:line`, a one-line summary and its concrete cost.

- **Reuse:** new code duplicating something the codebase has — grep shared
  modules and neighbouring files; name the helper to call.
- **Simplification:** redundant or derivable state, near-copies, deep nesting;
  name the simpler form.
- **Dead code and dependencies:** what the diff leaves unreachable or orphans —
  commented-out blocks; unused functions, parameters, imports, variables and
  exports; flags fixed at one value; unreachable branches; packages nothing
  imports any more, with their lockfile entries and the config, scripts and
  assets only they served. Before dropping a dependency, grep the tree for its
  imports and the CLI or build names it provides; afterwards refresh the
  lockfile and run the build and tests.
- **Efficiency:** repeated computation or I/O, independent work run serially,
  blocking work on startup or hot paths, long-lived closures pinning a large
  scope (prefer a class or struct holding only the fields it needs); name the
  cheaper form.
- **Altitude:** a symptom patched instead of the root cause, or special cases
  stacked on shared infrastructure; name the deeper, more general fix.

## 3. Apply

Merge findings on the same line or mechanism, then fix each. Skip, and note,
any that would change intended behaviour, reach well outside the diff without
a global-instruction reason, or are false positives. Verify with the project's
formatter, linter and tests. Report what was fixed and skipped (or that the
code was clean) and whether the review fanned out or ran inline.
