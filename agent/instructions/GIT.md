# Git

- Commit or push only when asked, in the project's commit style (e.g.
  Conventional Commits).
- Commits are SSH-signed through `/opt/1Password/op-ssh-sign`; push, pull and
  fetch use the 1Password agent (`~/.1password/agent.sock`). Each waits for me
  to approve a 1Password prompt.
- **A key or signing error means the prompt was not approved** ("No such
  identity", "Permission denied (publickey)", "failed to sign", "agent refused
  operation", "signing failed", a passphrase or approval error). Never work
  around it — no `--no-gpg-sign`, `commit.gpgsign=false`, other key, other
  remote or retry loop. Say the prompt needs approving and retry once after I
  confirm.
