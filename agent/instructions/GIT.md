# Git

**Commits are signed, and remote operations are gated by 1Password.**

- Commit or push only when asked. Follow the project's commit message style
  (e.g. Conventional Commits: `feat:`, `fix:`, `chore:`).

- Every commit is SSH-signed with a key held in 1Password: git calls
  `/opt/1Password/op-ssh-sign` (`commit.gpgsign = true`, `gpg.format = ssh`),
  and SSH requests (push, pull, fetch) go through the 1Password agent at
  `~/.1password/agent.sock`. Each of those waits for an approval prompt in the
  1Password app, so it only succeeds once I accept it.
- **A missing key or failed signature is the expected unaccepted prompt.** When
  a commit, push, or pull fails with an SSH/key error — "No such identity",
  "Permission denied (publickey)", "failed to sign", "agent refused operation",
  "sign_and_send_pubkey: signing failed", or a passphrase/approval error —
  assume the 1Password prompt was not accepted. Do not work around it: do not
  turn signing off (`--no-gpg-sign`, `commit.gpgsign=false`), use another key,
  switch the remote, or retry in a loop. Say the 1Password prompt needs
  approving and retry once after I confirm.
