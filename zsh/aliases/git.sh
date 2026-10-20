# Git aliases. omarchy-zsh's omadots provides `g`, `gcm`, `gcam`, `gcad`; the
# rest below are the oh-my-zsh `git` plugin's aliases (minus what omadots
# already covers), so the muscle memory transfers after dropping omz.
alias gst="git status"
alias gd="git diff"
alias gds="git diff --staged"
alias ga="git add"
alias gaa="git add --all"
alias gc="git commit"
alias gca="git commit --amend"
alias gcan="git commit --amend --no-edit"
alias gco="git checkout"
alias gcb="git checkout -b"
alias gb="git branch"
alias gba="git branch --all"
alias gbd="git branch --delete"
alias gp="git push"
alias gpf="git push --force-with-lease"
alias gpl="git pull"
alias glog="git log --oneline --decorate --graph"
alias gstp="git stash pop"
alias gsta="git stash apply"
alias gclean="git clean --force --directories -d"
alias gcp="git cherry-pick"

# Helper from oh-my-zsh's lib/git.zsh, used by gpsup / ggpush / ggpull.
git_current_branch() {
  local ref
  ref=$(command git symbolic-ref --quiet HEAD 2>/dev/null)
  local ret=$?
  if [[ $ret != 0 ]]; then
    [[ $ret == 128 ]] && return
    ref=$(command git rev-parse --short HEAD 2>/dev/null) || return
  fi
  echo ${ref#refs/heads/}
}

# Additional oh-my-zsh `git` plugin aliases (common set).
alias glo='git log --oneline --decorate'
alias gloga='git log --oneline --decorate --graph --all'
alias glol='git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset"'
alias gss='git status --short'
alias gsb='git status --short --branch'
alias gdca='git diff --cached'
alias gdup='git diff @{upstream}'
alias gsh='git show'
alias gapa='git add --patch'
alias gau='git add --update'
alias gcmsg='git commit --message'
alias gcn='git commit --verbose --no-edit'
alias gc!='git commit --verbose --amend'
alias gca!='git commit --verbose --all --amend'
alias gbD='git branch --delete --force'
alias gbl='git blame -w'
alias gsw='git switch'
alias gswc='git switch --create'
alias grh='git reset'
alias grhh='git reset --hard'
alias grhs='git reset --soft'
alias grs='git restore'
alias grst='git restore --staged'
alias gwipe='git reset --hard && git clean --force -df'
alias gf='git fetch'
alias gpr='git pull --rebase'
alias gpf!='git push --force'
alias gpsup='git push --set-upstream origin $(git_current_branch)'
alias ggpush='git push origin "$(git_current_branch)"'
alias ggpull='git pull origin "$(git_current_branch)"'
alias grb='git rebase'
alias grba='git rebase --abort'
alias grbc='git rebase --continue'
alias grbi='git rebase --interactive'
alias grbs='git rebase --skip'
alias gm='git merge'
alias gma='git merge --abort'
alias gmc='git merge --continue'
alias gstl='git stash list'
alias gstd='git stash drop'
alias gstc='git stash clear'
alias gstu='gsta --include-untracked'
alias gr='git remote'
alias grv='git remote --verbose'
alias gwt='git worktree'
alias gwta='git worktree add'
alias gwtls='git worktree list'
alias grt='cd "$(git rev-parse --show-toplevel || echo .)"'
