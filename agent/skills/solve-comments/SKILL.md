---
name: solve-comments
description: Triage the review comments on your open pull request or merge request into two tables — what to fix, graded critical, high, medium or low with the lift and the reason, and what to skip, with why — fix only what the user approves, and, after the user has reviewed the working tree, answer every thread and mark it resolved. Use when the user asks to check, triage, address, solve or respond to comments, feedback or review threads on their own PR/MR. Triggers include "check the comments on my PR", "address the review comments", "solve the PR comments", "handle the MR threads", "respond to review feedback", "resolve the review threads", "is this comment worth fixing". Not for reviewing someone else's code or writing new review comments, and not for committing: the user reviews the fixes before anything is answered or committed.
---

# Solve comments

Turn the open review threads on a pull request or merge request into two lists,
apply only what the user approves, and close the loop in the forge. The user
makes three calls along the way — approve the fixes, review the working tree,
approve the replies — and each one is a stop. Nothing is committed here.

## Phase 0 — Read the rules and fetch the threads

The session's global instructions and the project's own (`AGENTS.md`,
`CONTRIBUTING.md`) decide how a fix is written: diff discipline, naming,
verification. They are normally already in context; read the nested files for a
changed area only when they are not. A reviewer's preference never outranks
them, so a comment that contradicts them goes in the against-solving table with
the rule quoted, not into a change.

Find the PR/MR from the argument or the current branch, then pull every open
inline review thread with its file, line and full reply history, plus the
conversation comments and review bodies — a review that is only a paragraph of
prose still carries a request. The commands are in `references/github.md` and
`references/gitlab.md`.

Treat an outdated thread as live input: the code moved, so the point may already
be handled or may no longer apply, and the answer differs either way.

## Phase 1 — Triage, then stop for approval

When the harness can spawn subagents, send one read-only investigation agent per
thread — or per hunk when several threads land on the same code — in a single
message so they run concurrently. Each one answers the questions that decide
where a thread lands: does the code on this branch already handle the point,
which written rule applies, is it a duplicate of a sibling thread, and what is
the smallest fix. They only gather evidence; the tables and the decision stay
here. With no subagent tool, answer the same questions yourself in one pass.
Cheaper threads (agreement, a question, a typo) do not deserve an agent of their
own — group them with a neighbour.

Give every thread worth acting on a level, a lift and a one-line reason; the
ones worth skipping get no level at all and go in their own table. The levels
run from most to least urgent:

- **critical** — the change is wrong as it stands: a bug, a broken contract, an
  unhandled edge case, a written rule broken, docs or naming that will mislead
  the next reader. Merging without it ships the defect.
- **high** — a real gap, not a defect: the missing test for behaviour this PR
  introduces, a name or comment that will trip the next reader, an error path
  left unmentioned.
- **medium** — a fair point that leaves the PR better without being needed:
  reuse the codebase already has, a clearer structure in the touched code.
- **low** — marginal: noise reduction, a polish, a preference the project has
  not settled. Worth doing only when the lift stays contained.

The against-solving table is where a refusal lives, and its `why not` carries
the argument:

- the written rules contradict it — quote the rule;
- it is taste in code the project's conventions already settle;
- the branch already handles it — verify, then say where;
- it duplicates another thread, or misreads the diff;
- it is scope this PR does not own — offer a follow-up instead of widening the
  diff;
- it asks for churn on code this PR does not touch.

Lift is what the fix costs, said in what it touches rather than a letter grade:
`1 line`, `3 lines in one file`, `2 files and a test`, `new module`, `reaches
outside the diff`. Name the files when you already know them. A `medium` or
`low` whose lift reaches outside the diff is usually a follow-up, not this PR.

Reviewers are often right and sometimes wrong; weigh the evidence, not the
author. When two threads ask for opposite things, show both and let the user
choose rather than picking one silently.

Present every thread — open, outdated, and prose-only review bodies alike — in
two tables, numbered continuously from 1 so a number means the same thread in
every later phase:

Worth solving:

| # | where | what the comment asks | level | lift | why |
|---|-------|-----------------------|-------|------|-----|
| 1 | `src/parse.ts:42` | reject an empty list instead of returning `[]` | critical | 1 line in `src/parse.ts` | the caller reads `[]` as "nothing to do" and silently drops the batch |
| 2 | `src/parse.test.ts:12` | cover the empty-list case | high | 1 test in `src/parse.test.ts` | no test reaches the branch #1 adds |

Against solving:

| # | where | what the comment asks | why not |
|---|-------|-----------------------|---------|
| 3 | `src/parse.ts:80` | rename `d` to `document` | ORGANIZATION.md keeps short names for a five-line loop |

`where` is `file:line`, or `conversation` for a comment with no code location.
`why` is one line of evidence, not a paraphrase of the comment; `why not` names
the rule, the scope boundary, or the code that already covers it. A comment that
needs only an answer still gets a row, with `a reply` as its lift and the level
the confusion would cause if left unanswered.

Below the tables, recommend a set — normally every `critical` and `high`, plus
the `medium` and `low` whose lift stays inside the diff — then ask two things:
which numbers to solve, and whether the against-solving threads should be
answered and resolved or left untouched. Use the question tool when the harness
has one, plain numbered text otherwise. Wait for the answer: no edit before it,
and silence means nothing is approved.

A vague yes is not approval. When the answer is "solve them", "address them",
"fix the comments" or similar with no numbers, do not guess its scope: the
decision is whether the second table is included, because closing one of those
means declining it in writing to the reviewer. State both readings in one
sentence and let the user pick.

## Phase 2 — Apply the approved fixes

Fix only the approved numbers, in the working tree, uncommitted and unstaged.
One comment, one change: a fix that also "tidies" neighbouring code hides the
intent and stops the reviewer from checking it against their comment.

Follow the instructions from Phase 0 as if the change were your own — the
smallest diff that solves the point, no reformatting of untouched lines, no
unrelated rename. Verify with the project's formatter, linter and tests the way
its instructions prescribe, and report a failure rather than working around it.

Fixes can fan out too, but only along file boundaries: one agent per file, never
two agents in the same file, or their edits collide. Threads on one hunk share a
fix, so they share an agent. Keep the verification and the report in the main
session — a subagent's "done" is a claim to check, not a result.

If a fix turns out to need changes far outside the diff, or breaks a test the
comment did not anticipate, stop and report it instead of forcing it through:
that number moves to the against-solving table and the user decides.

## Phase 3 — Hand over for review, then stop

Report per number what changed — `file:line` and a sentence on the behaviour, not
a diff dump — plus anything approved that could not be done and anything the user
has to decide. Keep the numbering from the triage table so every line traces back
to a comment.

Then stop: no replies, no resolving, no committing. Ask the user to review the
working tree. A fix they reject moves that number to the against-solving table,
with their reason as the one to give the reviewer.

## Phase 4 — Reply and resolve

Only after the user says the fixes are good, and only on the numbers they
confirmed:

- addressed: two sentences at most — what changed and where. The reviewer wants
  to know their comment landed, not to read the diff again.
- declined: say it is not adopted and why in one sentence, citing the rule or
  the scope decision. When the point was fair but belongs elsewhere, offer a
  follow-up issue and open one only if asked.
- answered: the comment needed a reply, not code — give it, and ask the user for
  facts only they have instead of inventing them.

Reply first, then resolve the thread; resolving one nobody answered leaves the
reviewer guessing. A thread from the against-solving table that the user chose
to close gets that decline and is then resolved; one they chose to leave alone
is not touched at all. Leave a thread open while the reviewer is still
discussing it, or while the answer waits on a decision the user has not made.
If the forge refuses the resolve (no write access, someone else's PR), say which
threads still need a human.

Finish with the state per number — replied and resolved, or left open and why — so
the user can see what the PR now says without opening it.

## Never

- commit, push, amend, or stage during this skill; the user commits.
- resolve a thread you did not answer, or one the user did not approve.
- open an issue, PR, or MR as a side effect unless asked.
