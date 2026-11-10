---
name: commit
description: Split the working tree into atomic commits that follow the project's own commit rules, falling back to Conventional Commits when it defines none. Use when the user asks to commit, to make atomic or separate commits, to split the staged changes, or to turn the current diff into reviewable commits. Triggers include "commit this", "make atomic commits", "split these changes", "commit the working tree", "group these into commits". Not for pushing, opening a pull request, or reviewing code quality.
---

# Commit

Turn the current changes into atomic commits: one logical change per commit,
with messages the project's own rules prescribe.

## Phase 0 — Learn the rules

Read the global instructions loaded for the session and anything the project
says about commits: contributing guides, commit templates, release tooling.
Then run `git log --oneline -20`: the existing history is the strongest signal
of the style actually used, including which prefixes and scopes are accepted.

When nothing defines a style, use Conventional Commits: `type(scope): summary`
with `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`,
`chore` or `revert`. Keep the subject imperative, lowercase, without a trailing
period, and under about 72 characters. Put the reason for the change, and any
breaking change, in the body.

Project rules also cover tooling: keep signing and hooks as configured. A failed
signature or hook is a prompt or an error to surface, never something to bypass
with `--no-verify` or `--no-gpg-sign`.

## Phase 1 — Group the changes

List what changed and why (`git status`, `git diff`, `git diff --cached`), then
group it by intent. A behaviour change travels with its tests and its docs; an
unrelated refactor, rename or formatting pass is its own commit.

Split a mixed working tree with `git add -p` and per-path staging rather than
staging everything at once. Stage only the paths each group needs, and leave
ignored files and generated output out.

Each commit must stand on its own: it builds and its tests pass at that point.
When a change cannot be split without breaking that, keep it whole and say why.

## Phase 2 — Commit

For each group, in dependency order:

1. Stage exactly its hunks and paths.
2. Run the project's formatter, linter and tests on what will be committed, as
   its instructions prescribe. Report a failure instead of committing around
   it.
3. Write the message decided in Phase 0. The body explains why the change is
   made, not what the diff already shows, and references the issues it closes.

Do not amend, rebase or rewrite commits that are already pushed unless the user
asks for it.

## Phase 3 — Report

Show the commits you created (`git log --oneline -n <count>`), and list anything
still uncommitted with the reason it was left out. Do not push unless asked.
