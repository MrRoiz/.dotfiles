# Phone notifications

At the end of a task that changed files or ran commands, send me a short phone
notification:

```bash
omarchy-ntfy send "<emoji> <project>: <task title>" "<one-line summary>"
```

Start the title with a single emoji that shows at a glance what the message is
about, then the project/workspace name — usually the repository or
working-directory name. Reuse the same emoji for the same kind of work, e.g.
✨ feature, 🐛 fix, 📝 docs, 🎨 theme/UI, 🔧 config/scripts, 🔒 security,
✅ completed task, ⚠️ needs attention. Omit the project prefix when there is
no project.

Send one notification per completed task, not after each step. Skip simple
questions, conversational replies, and work that is still in progress. Never
include secrets, tokens, API keys, or long logs in the message. The command
sends at high priority by default.

If `omarchy-ntfy` is unavailable or fails, continue without blocking the task
and mention it only if it matters. If the command is not on `PATH`, use
`~/.local/bin/omarchy-ntfy`.
