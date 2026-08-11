#
# .zshrc
#

export ZSH="$HOME/.oh-my-zsh"
export ZSH_THEME=""
export MNEMOSYNE_EMBEDDING_MODEL="sentence-transformers/paraphrase-multilingual-mpnet-base-v2"
export HOMEBREW_NO_ASK=1
export HOMEBREW_AUTO_UPDATE_SECS=604800
export COMPOSER_MEMORY_LIMIT=-1

# Initialization that may perform console I/O must run before instant prompt.
[[ -r "$HOME/.zshrc.local.pre-p10k" ]] && source "$HOME/.zshrc.local.pre-p10k"

# Enable Powerlevel10k instant prompt.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

unset LSCOLORS
export CLICOLOR=1
unsetopt nomatch
export TIMEFMT=$'\nreal\t%*E\nuser\t%*U\nsys\t%*S'

# Keep PATH entries unique while preserving the system defaults.
typeset -U path PATH
path=("$HOME/.omlx/bin" "$HOME/.local/bin" "$HOME/bin" $path)

brew_prefix="${HOMEBREW_PREFIX:-}"
if [[ -z "$brew_prefix" ]]; then
  if [[ -x /opt/homebrew/bin/brew ]]; then
    brew_prefix=/opt/homebrew
  elif [[ -x /usr/local/bin/brew ]]; then
    brew_prefix=/usr/local
  fi
fi

if [[ -n "$brew_prefix" ]]; then
  python_prefix="$("$brew_prefix/bin/brew" --prefix python@3 2>/dev/null)"
  [[ -n "$python_prefix" ]] && path=("$python_prefix/libexec/bin" $path)
fi

plugins=(autoswitch_virtualenv macos brew ansible git git-auto-fetch git-commit git-lfs git-prompt colored-man-pages colorize common-aliases emoji emoji-clock fancy-ctrl-z python pip ssh vscode ssh-agent sudo command-not-found history iterm2 podman history-substring-search)

# Oh My Zsh initializes completion and history-substring-search.
zstyle ':completion:*' matcher-list \
  'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' \
  'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*'
zstyle :omz:plugins:ssh-agent lazy yes

[[ -r "$ZSH/oh-my-zsh.sh" ]] && source "$ZSH/oh-my-zsh.sh"

if [[ -n "$brew_prefix" ]]; then
  [[ -r "$brew_prefix/share/powerlevel10k/powerlevel10k.zsh-theme" ]] && source "$brew_prefix/share/powerlevel10k/powerlevel10k.zsh-theme"
  [[ -r "$brew_prefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] && source "$brew_prefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

  export NVM_DIR="$HOME/.nvm"
  [[ -s "$brew_prefix/opt/nvm/nvm.sh" ]] && source "$brew_prefix/opt/nvm/nvm.sh"
  [[ -s "$brew_prefix/opt/nvm/etc/bash_completion.d/nvm" ]] && source "$brew_prefix/opt/nvm/etc/bash_completion.d/nvm"
fi

[[ -r "$HOME/.iterm2_shell_integration.zsh" ]] && source "$HOME/.iterm2_shell_integration.zsh"
[[ -r "$HOME/.aliases" ]] && source "$HOME/.aliases"
[[ -x "$HOME/bin/update-all" ]] && alias ua='$HOME/bin/update-all'
[[ -r /etc/zsh/zshrc.local ]] && source /etc/zsh/zshrc.local
[[ -r "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

# Load the generated prompt configuration after the theme.
[[ -r "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"

# Syntax highlighting must be sourced last.
[[ -n "$brew_prefix" && -r "$brew_prefix/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] && source "$brew_prefix/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
