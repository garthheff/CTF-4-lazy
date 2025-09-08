#!/usr/bin/env bash
set -euo pipefail

# Resolve target user and home (safe even if invoked with sudo)
if [[ ${SUDO_USER-} && $EUID -eq 0 ]]; then
  TARGET_USER="$SUDO_USER"
  HOME_DIR="$(eval echo "~$TARGET_USER")"
  LOGIN_SHELL="$(getent passwd "$TARGET_USER" | cut -d: -f7 || true)"
else
  TARGET_USER="${USER:-$(id -un)}"
  HOME_DIR="$HOME"
  LOGIN_SHELL="${SHELL:-/bin/bash}"
fi

detect_shell() {
  case "$(basename "$LOGIN_SHELL")" in
    zsh) SHELL_NAME="zsh"; RC_FILE="$HOME_DIR/.zshrc" ;;
    bash|sh) SHELL_NAME="bash"; RC_FILE="$HOME_DIR/.bashrc" ;;
    *) SHELL_NAME="bash"; RC_FILE="$HOME_DIR/.bashrc" ;;
  esac
}

ensure_fzf() {
  if command -v fzf >/dev/null 2>&1; then return; fi
  echo "fzf not found."
  read -rp "Install fzf now? [Y/n] " yn
  yn="${yn:-Y}"
  case "$yn" in
    Y|y)
      if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        case "$ID" in
          debian|ubuntu|kali) sudo apt update && sudo apt install -y fzf ;;
          arch|manjaro) sudo pacman -S --needed fzf ;;
          fedora|rhel|centos) sudo dnf install -y fzf || sudo yum install -y fzf ;;
          *) echo "Unknown distro $ID. Please install fzf manually." ; exit 1 ;;
        esac
      elif command -v brew >/dev/null 2>&1; then
        brew install fzf
        "$(brew --prefix)"/opt/fzf/install || true
      else
        echo "No supported package manager detected. Please install fzf manually."
        exit 1
      fi
      ;;
    *) echo "Please install fzf and re-run install." ; exit 1 ;;
  esac
}

ensure_envsubst() {
  if command -v envsubst >/dev/null 2>&1; then return; fi
  echo "envsubst not found (needed to expand \$VARS while preserving quotes)."
  read -rp "Install envsubst now? [Y/n] " yn
  yn="${yn:-Y}"
  case "$yn" in
    Y|y)
      if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        case "$ID" in
          debian|ubuntu|kali) sudo apt update && sudo apt install -y gettext-base ;;  # provides envsubst
          arch|manjaro) sudo pacman -S --needed gettext ;;
          fedora|rhel|centos) sudo dnf install -y gettext || sudo yum install -y gettext ;;
          *) echo "Unknown distro $ID. Please install 'gettext' manually." ; exit 1 ;;
        esac
      elif command -v brew >/dev/null 2>&1; then
        brew install gettext
        brew link --force gettext || true
      else
        echo "No supported package manager detected. Please install 'gettext' manually."
        exit 1
      fi
      ;;
    *) echo "Please install envsubst (gettext) and re-run install." ; exit 1 ;;
  esac
}

main() {
  detect_shell
  echo "Detected shell: $SHELL_NAME (rc: $RC_FILE)"

  ensure_fzf
  ensure_envsubst

  TARGET_DIR="$HOME_DIR/.ctf4l"
  mkdir -p "$TARGET_DIR"
  cp -f scripts/ctf4l.zsh "$TARGET_DIR"/
  cp -f scripts/ctf4l.bash "$TARGET_DIR"/

  [[ -f "$HOME_DIR/.cmdvars" ]] || cp -f examples/cmdvars "$HOME_DIR/.cmdvars"
  [[ -f "$HOME_DIR/.cmdlist" ]] || cp -f examples/cmdlist "$HOME_DIR/.cmdlist"

  if [[ "$SHELL_NAME" = "zsh" ]]; then
    SRC_LINE='source $HOME/.ctf4l/ctf4l.zsh'
  else
    SRC_LINE='source $HOME/.ctf4l/ctf4l.bash'
  fi

  # Append source line once
  if ! grep -Fq "$SRC_LINE" "$RC_FILE" 2>/dev/null; then
    printf "\n# ctf4l\n%s\n" "$SRC_LINE" >> "$RC_FILE"
    echo "Added ctf4l to $RC_FILE"
  else
    echo "ctf4l already present in $RC_FILE"
  fi

  echo
  echo "Usage:"
  echo "  setip <ip>         # set target IP"
  echo "  setwordlist <file> # set wordlist path"
  echo "  setvar NAME VALUE  # generic variable"
  echo "  listvars           # show current variables"
  echo "  Press Alt+c to open the menu"
  echo

  # Offer to reload rc (temporarily relax -u to avoid 'unbound variable' in user rc)
  echo "Do you want me to reload your shell config now? (y/n)"
  read -r ans
  if [[ "$ans" =~ ^[Yy]$ ]]; then
    set +u
    # shellcheck disable=SC1090
    . "$RC_FILE"
    set -u
    echo "Reloaded: $RC_FILE"
  else
    echo "Reload later with:"
    echo '[ -n "${ZSH_VERSION-}" ] && source ~/.zshrc || { [ -n "${BASH_VERSION-}" ] && source ~/.bashrc; }'
  fi
}

main "$@"
