# Phone notifications

At the end of a task that changed files or ran commands, send me a short phone
notification:

```bash
omarchy-ntfy send "<project>: <task title>" "<one-line summary>"
```

Use the project/workspace name — usually the repository or working-directory
name — as the title prefix when one is available. Omit the prefix when it is
not.

Send one notification per completed task, not after each step. Skip simple
questions, conversational replies, and work that is still in progress. Never
include secrets, tokens, API keys, or long logs in the message. The command
sends at high priority by default.

If `omarchy-ntfy` is unavailable or fails, continue without blocking the task
and mention it only if it matters. If the command is not on `PATH`, use
`~/.local/bin/omarchy-ntfy`.
