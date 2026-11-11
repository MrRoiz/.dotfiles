---
name: polish
description: Review the changed code for reuse, simplification, dead code and dead dependencies, efficiency and altitude, then apply the fixes — quality only, no bug hunting. Use when the user asks to simplify, tidy, clean up or polish the current diff or recent changes, or after finishing a change. Triggers include "simplify this", "polish the diff", "clean this up", "tidy the changes", "review my changes for quality", "make this code simpler". Not for hunting correctness bugs or reviewing a pull request.
---

# Polish

You are improving the quality of the changed code, not hunting for bugs. Review
it for reuse, simplification, dead code and dead dependencies, efficiency and
altitude, then fix what you find.

## Phase 0 — Gather the diff

Run `git diff @{upstream}` (or `git diff main` / `git diff HEAD~1` when there is
no upstream) for the unified diff under review, working-tree changes included.
If that range is empty and the user named a target (a PR number, a branch, a
file path), review that instead. That diff is the scope: leave untouched code
alone, except for what the global instructions require removing with it.

Before changing anything, follow the global instructions loaded for the session;
they are normally already in context, so read only a nested instruction file for
a changed file's directory that is not. Those rules govern this review and win
where they disagree with it — a project that demands minimal diffs and no
unrelated reformatting still gets exactly that.

## Phase 1 — Review

When the harness can spawn subagents, launch one per angle in a single message
so they run concurrently, and give different angles different agent types when
that fits better (a fast search-oriented agent for reuse and dead code, a
general agent for altitude). The angles are independent, so no agent needs
another's findings.

When no subagent tool is available, review the diff against each angle in turn
yourself, in one pass, without skipping one for lack of fan-out.

Each angle yields findings with `file`, `line`, a one-line `summary`, and the
concrete cost: what is duplicated, wasted, or harder to maintain.

### Reuse

Flag new code that re-implements something the codebase already has. Grep the
shared and utility modules and the files adjacent to the change, and name the
existing helper to call instead.

### Simplification

Flag unnecessary complexity the diff adds: redundant or derivable state,
copy-paste with slight variation, deep nesting. Name the simpler form that does
the same job.

### Dead code and dead dependencies

Flag what the diff leaves unreachable and what its removals orphan. For code:
commented-out blocks, unused functions, parameters, imports, variables and
exports, flags fixed at one value, and branches no caller can reach. For
dependencies: a package, crate, gem or module nothing imports any more, its
lockfile entry, and the config, scripts or assets that served only the removed
feature.

Verify a dependency before removing it: grep the whole tree for its imports and
for the CLI or build names it provides, then remove it, refresh the lockfile,
and run the build and tests.

### Efficiency

Flag wasted work the diff introduces: redundant computation or repeated I/O,
independent operations run sequentially, blocking work added to startup or hot
paths. Also flag long-lived objects built from closures or captured
environments — they keep the entire enclosing scope alive for the object's
lifetime (a memory leak when that scope holds large values); prefer a
class/struct that copies only the fields it needs. Name the cheaper alternative.

### Altitude

Check that each change fixes the root cause at the right depth instead of
patching a symptom with a fragile bandaid. Special cases layered on shared
infrastructure are a sign the fix is not deep enough — prefer the simpler, more
general change to the underlying mechanism, and name that change.

## Phase 2 — Apply the fixes

Dedup findings that point at the same line or mechanism, then fix each remaining
one directly. Skip a finding when its fix would change intended behaviour, when
it needs changes well outside the reviewed diff that the global instructions do
not require, or when you judge it a false positive; note the skip instead of
arguing with it.

Verify what you changed with the project's own formatter, linter and tests, as
its instructions prescribe. Finish with a brief summary of what was fixed and
what was skipped, or confirm the code was already clean, and say whether the
review fanned out or ran as a single inline pass.
