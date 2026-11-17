---
name: solve-comments
description: Triage the review comments on your own open PR/MR into a fix table (graded, with lift) and a skip table (with why), fix only what the user approves, then reply to and resolve the threads once the user has reviewed the fixes. Use when asked to check, triage, address, solve, respond to or resolve review comments or threads on your PR/MR, or whether a comment is worth fixing. Not for reviewing others' code or committing.
---

# Solve comments

Three user decisions are hard stops: which fixes to make, whether the fixed
working tree is good, and which threads to answer. Nothing is staged,
committed or pushed here, and no issue, PR or MR is opened as a side effect.

## 0. Rules and threads

The global and project instructions (`AGENTS.md`, `CONTRIBUTING.md`; read
nested ones for a changed area when not in context) decide how fixes are
written. A reviewer's preference never outranks them: a comment that
contradicts them is skipped with the rule quoted.

Find the PR/MR from the argument or the current branch. Fetch every unresolved
inline thread (file, line, full replies), conversation comment and non-empty
review body — a prose-only review still carries requests — with the commands
in `references/github.md` or `references/gitlab.md`. An outdated thread is
still live: the code moved, so the point may be handled or moot, and the reply
differs.

## 1. Triage, then stop

With subagents, send one read-only investigator per thread (per hunk when
threads share code) in a single message, folding trivial threads (agreement, a
question, a typo) into a neighbour's; without them, do it yourself in one pass.
Each answers: does the branch already handle it, which written rule applies,
does it duplicate another thread, what is the smallest fix. They gather
evidence; the tables and decisions stay here.

Levels, for threads worth solving:

- **critical** — the change is wrong as it stands (bug, broken contract,
  unhandled edge case, broken written rule, misleading docs or naming); merging
  ships the defect.
- **high** — a real gap, not a defect: a missing test for new behaviour, a name
  or comment that will trip the next reader, an unmentioned error path.
- **medium** — better but not needed: existing reuse, clearer structure in the
  touched code.
- **low** — marginal polish or an unsettled preference; only when the lift
  stays contained.

Skip a thread (no level) when the written rules contradict it (quote the
rule), the project's conventions already settle the taste, the branch already
handles it (verify, say where), it duplicates another thread or misreads the
diff, it is scope this PR does not own (offer a follow-up), or it asks for
churn in untouched code.

Lift is what the fix touches — `1 line`, `3 lines in one file`, `2 files and a
test`, `new module`, `reaches outside the diff` — naming files when known. A
`medium` or `low` that reaches outside the diff is usually a follow-up. A
comment that needs only an answer gets lift `a reply` and the level its
confusion would cause. Weigh evidence, not the author; when threads conflict,
show both and let the user choose.

Number all threads continuously from 1 across both tables; a number keeps its
meaning in later phases. `where` is `file:line` or `conversation`; `why` is one
line of evidence, not a paraphrase; `why not` names the rule, scope boundary or
covering code.

Worth solving:

| # | where | what the comment asks | level | lift | why |
|---|-------|-----------------------|-------|------|-----|
| 1 | `src/parse.ts:42` | reject an empty list instead of returning `[]` | critical | 1 line in `src/parse.ts` | the caller reads `[]` as "nothing to do" and drops the batch |
| 2 | `src/parse.test.ts:12` | cover the empty-list case | high | 1 test in `src/parse.test.ts` | no test reaches the branch #1 adds |

Against solving:

| # | where | what the comment asks | why not |
|---|-------|-----------------------|---------|
| 3 | `src/parse.ts:80` | rename `d` to `document` | name length follows scope (PRINCIPLES.md); `d` lives in a five-line loop |

Recommend a set — normally every `critical` and `high`, plus `medium` and `low`
whose lift stays in the diff — and ask (question tool if available, numbered
text otherwise): which numbers to solve, and whether the against-solving
threads get a decline and resolve or stay untouched. Wait; silence approves
nothing. A vague "solve them" is not approval: state the two readings (with or
without the second table, which declines in writing) and let the user pick.

## 2. Fix the approved numbers

Unstaged, in the working tree. One comment, one change — no tidying nearby, so
the reviewer can check it against their comment. Follow the session's diff and
verification rules; report failures instead of working around them. Fixes may
fan out one agent per file (threads on one hunk share an agent); verification
and the report stay here, since a subagent's "done" is a claim to check. A fix
that reaches far outside the diff or breaks an unanticipated test stops: it
moves to the against-solving table for the user to decide.

## 3. Hand over, then stop

Report per number `file:line` and one sentence on the behaviour, plus anything
approved but not done and any open decision. Then stop — no replies, resolves
or commits — and ask the user to review the working tree. A rejected fix moves
to the against-solving table with the user's reason.

## 4. Reply and resolve

Only after the user approves the fixes, on the numbers they confirmed:

- addressed: at most two sentences, what changed and where — the reviewer
  needs to see their comment landed, not reread the diff.
- declined: not adopted, and why, in one sentence citing the rule or scope;
  offer a follow-up issue when the point fits elsewhere, and open it only if
  asked.
- answered: the reply the comment needed; ask the user for facts only they
  have instead of inventing them.

Reply, then resolve; never resolve an unanswered thread. Against-solving
threads the user chose to close get the decline and a resolve; the rest stay
untouched. Leave a thread open while the reviewer is still discussing it or
the answer waits on a user decision. If the forge refuses a resolve (no write
access, someone else's PR), list the threads that need a human. Finish with
each number's state: replied and resolved, or open and why.
