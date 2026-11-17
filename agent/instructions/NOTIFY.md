# Phone notifications

After a task that changed files or state, send one notification:

```bash
omarchy-ntfy send "<emoji> <project>: <task title>" "<one-line summary>"
```

- `<project>` is the repository or working-directory name; drop the prefix
  when there is none. `<emoji>` marks the kind of work, the same one each time,
  e.g. ✨ feature, 🐛 fix, 📝 docs, 🎨 theme/UI, 🔧 config/scripts,
  🔒 security, ✅ task done, ⚠️ needs attention.
- One per completed task — not per step, nor for questions, conversation or
  unfinished work. No secrets, tokens or long logs.
- Not on `PATH`? Use `~/.local/bin/omarchy-ntfy`. If it fails, carry on and
  mention it only if it matters.
