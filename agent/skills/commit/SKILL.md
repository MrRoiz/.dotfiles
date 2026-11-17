---
name: commit
description: Split the working tree into atomic commits in the project's commit style (Conventional Commits by default). Use when asked to commit, or to split or group the working tree or staged changes into commits. Not for pushing, PRs or code review.
---

# Commit

1. **Learn the style** from the project's commit rules (contributing guide,
   commit template, release tooling) and `git log --oneline -20`, the best
   evidence of the prefixes and scopes in use. Default: Conventional Commits —
   `type(scope): summary` with `feat`, `fix`, `docs`, `style`, `refactor`,
   `perf`, `test`, `build`, `ci`, `chore` or `revert`; imperative, lowercase,
   no trailing period, about 72 characters at most; the body holds the reason
   and any breaking change.
2. **Group by intent** from `git status`, `git diff` and `git diff --cached`. A
   behaviour change travels with its tests and docs; an unrelated refactor,
   rename or formatting pass is its own commit. Every commit must build and
   pass its tests on its own; if a change can't be split that way, keep it
   whole and say why.
3. **Commit each group in dependency order.** Stage exactly its paths and hunks
   (`git add -p`, per-path) — never everything at once, never ignored or
   generated files. Run the project's checks on what will be committed and
   report a failure instead of committing around it. The body says why, not
   what the diff shows, and references the issues it closes. Surface a failed
   signature or hook; never bypass it (`--no-verify`, `--no-gpg-sign`). Don't
   amend, rebase or rewrite pushed commits unless asked.
4. **Report** the new commits (`git log --oneline -n <count>`) and what stays
   uncommitted, with why. Don't push unless asked.
