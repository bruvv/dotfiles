#!/usr/bin/env bash

set -euo pipefail

if [[ $EUID -eq 0 ]]; then
  printf "Run this installer without sudo. It will request sudo when needed.\n" >&2
  exit 1
fi

if [[ $(uname -s) != "Darwin" ]]; then
  printf "This installer only supports macOS.\n" >&2
  exit 1
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
backup_suffix="$(date +%Y%m%d-%H%M%S).$$"

check_configuration() {
  /bin/bash -n "${script_dir}/install.sh"
  /bin/bash -n "${script_dir}/.osx"
  /bin/zsh -n "${script_dir}/.zshrc"
  /usr/bin/vim -Nu "${script_dir}/.vimrc" -n -i NONE -es '+qall!'
  printf "Configuration check passed.\n"
}

confirm() {
  local prompt answer
  prompt="$1"

  if ! read -r -p "${prompt} [j/N] " answer; then
    return 1
  fi

  case "$answer" in
    [Jj]|[Jj][Aa]|[Yy]|[Yy][Ee][Ss]) return 0 ;;
    *) return 1 ;;
  esac
}

load_homebrew() {
  if command -v brew >/dev/null 2>&1; then
    return
  fi

  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

install_homebrew() {
  load_homebrew
  if command -v brew >/dev/null 2>&1; then
    return
  fi

  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  load_homebrew
  command -v brew >/dev/null 2>&1 || {
    printf "Homebrew installation failed.\n" >&2
    return 1
  }
}

configure_zprofile() {
  local brew_path profile_path
  brew_path="$(command -v brew)"
  profile_path="${HOME}/.zprofile"

  if grep -q 'brew shellenv' "$profile_path" 2>/dev/null; then
    return
  fi

  if [[ -L "$profile_path" ]]; then
    printf "Skipped %s because it is a symlink; add brew shellenv to its source file.\n" "$profile_path" >&2
    return
  fi

  if [[ -e "$profile_path" ]]; then
    cp -p "$profile_path" "${profile_path}.backup.${backup_suffix}"
  fi
  # shellcheck disable=SC2016
  printf '\neval "$(%s shellenv)"\n' "$brew_path" >> "$profile_path"
}

install_oh_my_zsh() {
  local custom_plugin_dir oh_my_zsh_dir
  oh_my_zsh_dir="${HOME}/.oh-my-zsh"

  if [[ ! -r "${oh_my_zsh_dir}/oh-my-zsh.sh" ]]; then
    if [[ -e "$oh_my_zsh_dir" ]]; then
      printf "%s exists but is not a valid Oh My Zsh installation.\n" "$oh_my_zsh_dir" >&2
      return 1
    fi
    git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$oh_my_zsh_dir"
  fi

  custom_plugin_dir="${oh_my_zsh_dir}/custom/plugins/autoswitch_virtualenv"
  if [[ ! -d "$custom_plugin_dir" ]]; then
    git clone --depth=1 https://github.com/MichaelAquilina/zsh-autoswitch-virtualenv.git "$custom_plugin_dir"
  fi
}

link_dotfile() {
  local source_path="$1" target_path="$2"
  if [[ -L "$target_path" && "$(readlink "$target_path")" == "$source_path" ]]; then
    return
  fi

  if [[ -e "$target_path" || -L "$target_path" ]]; then
    mv "$target_path" "${target_path}.backup.${backup_suffix}"
  fi
  ln -s "$source_path" "$target_path"
}

install_zsh_configuration() {
  local formulae
  formulae=(
    git-lfs
    nvm
    pipx
    powerlevel10k
    pygments
    python@3
    ssh-copy-id
    zsh-autosuggestions
    zsh-syntax-highlighting
  )

  install_homebrew
  configure_zprofile
  brew install --no-ask "${formulae[@]}"
  brew install --cask --no-ask font-meslo-lg-nerd-font
  git lfs install
  install_oh_my_zsh

  mkdir -p "${HOME}/.nvm" "${HOME}/.ssh"
  chmod 700 "${HOME}/.ssh"
  link_dotfile "${script_dir}/.zshrc" "${HOME}/.zshrc"

  printf "Zsh configuration installed. Run 'p10k configure' to choose your prompt appearance.\n"
}

install_vim_configuration() {
  link_dotfile "${script_dir}/.vimrc" "${HOME}/.vimrc"
  printf "Vim configuration installed.\n"
}

apply_macos_configuration() {
  sudo -v
  /bin/bash "${script_dir}/.osx" --no-restart
  if [[ $(sudo systemsetup -getrestartfreeze) != *": On" ]]; then
    sudo systemsetup -setrestartfreeze on
  fi
  sudo defaults write "/Library/Application Support/CrashReporter/DiagnosticMessagesHistory.plist" \
    AutoSubmit -bool false
  sudo defaults write "/Library/Application Support/CrashReporter/DiagnosticMessagesHistory.plist" \
    ThirdPartyDataSubmit -bool false
  sudo defaults delete /.Spotlight-V100/VolumeConfiguration Exclusions 2>/dev/null || true
  printf "macOS configuration applied. Restart your Mac to apply all settings.\n"
}

if [[ ${1:-} == "--check" ]]; then
  check_configuration
  exit
elif [[ $# -ne 0 ]]; then
  printf "Usage: %s [--check]\n" "$0" >&2
  exit 2
fi

if confirm "Volledige zsh-configuratie installeren?"; then
  install_zsh_configuration
fi

if confirm "Vim-configuratie installeren?"; then
  install_vim_configuration
fi

if confirm "macOS-instellingen toepassen?"; then
  apply_macos_configuration
fi

printf "Done.\n"
