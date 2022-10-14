#!/usr/bin/env bash

case $- in
*i*) ;;  # interactive
*) return ;;
esac

_have() { type "$1" &>/dev/null; }
# shellcheck source=/dev/null
_source_if() { [[ -f "$1" && -r "$1" ]] && source "$1"; }

# fcitx5
export XMODIFIERS=@im=fcitx
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export INPUT_METHOD=fcitx
export SDL_IM_MODULE=fcitx

# time zone
export LC_TIME="zh_CN.UTF-8"

# qt theme
export QT_QPA_PLATFORMTHEME=qt5ct

export EDITOR='vim'
export TERMINAL="st"
export BROWSER="firefox"

# fo 'go`
export GOPATH="$HOME/.local/share/go"
export GOBIN="$HOME/.local/bin"
export GOPROXY=direct
export CGO_ENABLED=0

pathappend () {
  test -d "$1" || return
  case ":$PATH:" in
    *:"$1":*)
      ;;
    *)
      PATH="${PATH:+$PATH:}$1"
  esac
}

pathprepend () {
  test -d "$1" || return
  case ":$PATH:" in
    *:"$1":*)
      ;;
    *)
      PATH="$1${PATH:+":$PATH"}"
  esac
}

pathprepend "$HOME/.local/bin"
pathprepend "$HOME/.cargo/bin"
pathprepend "$HOME/dots/scripts/bin"

# bash shell options
shopt -s globstar
shopt -s dotglob
shopt -s extglob

# history
HISTFILE=~/.cache/bash_history
HISTTIMEFORMAT="%y-%m-%d %H:%M:%S "
HISTCONTROL=ignoreboth
HISTSIZE=5000
HISTFILESIZE=10000
shopt -s histappend

# disable control-s accidental terminal stops
stty stop undef

__ps1() {
  COLOR_NONE="\[\e[0m\]"
  GREY="\[\e[1;90m\]"
  RED="\[\e[1;31m\]"
  GREEN="\[\e[1;32m\]"
  YELLOW="\[\e[1;33m\]"
  BLUE="\[\e[1;34m\]"
  MAGENTA="\[\e[1;35m\]"
  CYAN="\[\e[36m\]"

  BRANCH=''
  if git branch > /dev/null 2>&1; then
    # Note that for new repo without commit, git rev-parse --abbrev-ref HEAD will error out.
    if git rev-parse --abbrev-ref HEAD > /dev/null 2>&1; then
      BRANCH="${COLOR_NONE}(${GREEN}$(git rev-parse --abbrev-ref HEAD)${COLOR_NONE})"
    else
      BRANCH="${COLOR_NONE}()"
    fi
  fi

  PS1=""
  PS1+="${CYAN}${VIRTUAL_ENV_PROMPT% }"
  PS1+="${RED}["
  PS1+="${YELLOW}\u"  # username
  PS1+="${GREY}@"
  PS1+="${BLUE}\h "   # hostname
  PS1+="${MAGENTA}\w"    # working directory
  PS1+="${RED}]"
  PS1+="${BRANCH}"
  # PS1+="${COLOR_NONE} -> (${BLUE}\D{%F}${GREY}@${BLUE}\t${COLOR_NONE})\n"  # for server(display time)
  PS1+="${COLOR_NONE}$ "
}

export PROMPT_COMMAND=__ps1

SetProxy() {
  local prefix=http://127.0.0.1
  if echo "$1" | grep -Pq "^\d+$" || ! env | grep -Eq "^(http|https|all)_proxy"; then
    # 7890 20171
    export {http,https,all}_proxy="${prefix}:${1:-7890}"
    env | grep -E --color=always "^(http|https|all)_proxy"
  else
    unset {http,https,all}_proxy
    echo "Unset all proxy"
  fi
} && export SetProxy

# export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export MANPAGER="sh -c 'col -bx | nvim -R -c \"set ft=man\" -'"

export FZF_DEFAULT_OPTS="--no-mouse --height 50% --reverse --multi --info=inline"
for file in /usr/share/fzf/{*,*/*}.bash; do
  _source_if $file
done

alias sudo='sudo -E'
alias grep='grep --color=auto'
alias cp='cp -iv'
alias mv='mv -iv'
alias diff='diff --color -u'
alias rm='gio trash'
alias rml='gio trash --list'
alias rme='gio trash --empty'
if _have exa; then
  alias ll='exa -lhg --group-directories-first'
  alias ls='exa --group-directories-first'
  alias l='exa -lhga --group-directories-first'
  alias tree='exa --tree'
else
  alias ls='ls --color=auto --group-directories-first'
  alias ll='ls -lh --color=auto --group-directories-first'
  alias l='ls -lhA --color=auto --group-directories-first'
fi
alias ldf='duf --only local'
alias clear='printf "\e[H\e[2J"'
alias c='printf "\e[H\e[2J"'

alias hexedit='hexedit --color'
alias vi=vim
alias nv=nvim
alias sw=devour
alias btl=bluetoothctl
alias nlist='nmcli device wifi list'
alias nconn='nmcli device wifi connect'
alias pc='env | grep -E "^(http|https|all)_proxy"'
alias a8='aria2c -x 8'

alias gs='git status'
alias gd='git diff'

# completion
# shellcheck source=/dev/null
# _have pandoc && . <(pandoc --bash-completion)

# https://gist.github.com/toschneck/2df90c66e0f8d4c6567d69a36bfc5bcd
_have docker && _source_if "$HOME/.local/share/docker/completion.bash"

eval "$(zoxide init bash --cmd j)"
