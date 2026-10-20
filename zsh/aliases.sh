alias tf="terraform"
alias tg="terragrunt"

# oh-my-zsh's directories lib (md/rd were always available before Omarchy).
alias md="mkdir -p"
alias rd="rmdir"

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

# oh-my-zsh `docker` plugin aliases (the pre-Omarchy plugin set).
alias dbl='docker build'
alias dcin='docker container inspect'
alias dcls='docker container ls'
alias dclsa='docker container ls -a'
alias dcprune='docker container prune'
alias dib='docker image build'
alias dii='docker image inspect'
alias dils='docker image ls'
alias dipu='docker image push'
alias dipru='docker image prune -a'
alias dirm='docker image rm'
alias dit='docker image tag'
alias dlo='docker container logs'
alias dnc='docker network create'
alias dncn='docker network connect'
alias dndcn='docker network disconnect'
alias dni='docker network inspect'
alias dnls='docker network ls'
alias dnprune='docker network prune'
alias dnrm='docker network rm'
alias dpo='docker container port'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias dpu='docker pull'
alias dr='docker container run'
alias drit='docker container run -it'
alias drm='docker container rm'
alias 'drm!'='docker container rm -f'
alias dsprune='docker system prune'
alias dst='docker container start'
alias drs='docker container restart'
alias dsta='docker stop $(docker ps -q)'
alias dstp='docker container stop'
alias dsts='docker stats'
alias dtop='docker top'
alias dvi='docker volume inspect'
alias dvls='docker volume ls'
alias dvprune='docker volume prune'
alias dxc='docker container exec'
alias dxcit='docker container exec -it'
