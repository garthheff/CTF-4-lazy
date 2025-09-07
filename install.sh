---

## install.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

# Detect shell rc and shell type
detect_shell() {
  if [ -n "${ZSH_VERSION:-}" ]; then
    SHELL_NAME="zsh"
    RC_FILE="$HOME/.zshrc"
  elif [ -n "${BASH_VERSION:-}" ]; then
    SHELL_NAME="bash"
    RC_FILE="$HOME/.bashrc"
  else
    # fallback using login shell
    case "$(basename "${SHELL:-}")" in
      zsh) SHELL_NAME="zsh"; RC_FILE="$HOME/.zshrc" ;;
      bash) SHELL_NAME="bash"; RC_FILE="$HOME/.bashrc" ;;
      *) echo "Could not detect shell. Defaulting to bash rc (~/.bashrc)."
         SHELL_NAME="bash"; RC_FILE="$HOME/.bashrc" ;;
    esac
  fi
}

ensure_fzf() {
  if command -v fzf >/dev/null 2>&1; then
    return
  fi
  echo "fzf not found."
  read -rp "Install fzf now? [Y/n] " yn
  yn="${yn:-Y}"
  case "$yn" in
    Y|y)
      if [ -f /etc/os-release ]; then
        . /etc/os-release
        case "$ID" in
          debian|ubuntu|kali) sudo apt update && sudo apt install -y fzf ;;
          arch|manjaro) sudo pacman -S --needed fzf ;;
          fedora|rhel|centos) sudo dnf install -y fzf || sudo yum install -y fzf ;;
          *) echo "Unknown distro $ID. Please install fzf manually."; exit 1 ;;
        esac
      elif command -v brew >/dev/null 2>&1; then
        brew install fzf
        "$(brew --prefix)"/opt/fzf/install || true
      else
        echo "No supported package manager detected. Please install fzf manually."
        exit 1
      fi
      ;;
    *) echo "Please install fzf and re-run install."; exit 1 ;;
  esac
}

main() {
  detect_shell
  echo "Detected shell: $SHELL_NAME (rc: $RC_FILE)"

  ensure_fzf

  TARGET_DIR="$HOME/.ctf4l"
  mkdir -p "$TARGET_DIR"
  cp -f scripts/ctf4l.zsh "$TARGET_DIR"/
  cp -f scripts/ctf4l.bash "$TARGET_DIR"/

  # Seed example configs if missing
  [ -f "$HOME/.cmdvars" ] || cp -f examples/cmdvars "$HOME/.cmdvars"
  [ -f "$HOME/.cmdlist" ] || cp -f examples/cmdlist "$HOME/.cmdlist"

  # Add source line if not present
  case "$SHELL_NAME" in
    zsh)
      SRC_LINE='source $HOME/.ctf4l/ctf4l.zsh'
      ;;
    bash)
      SRC_LINE='source $HOME/.ctf4l/ctf4l.bash'
      ;;
  esac

  if ! grep -Fq "$SRC_LINE" "$RC_FILE" 2>/dev/null; then
    printf "\n# ctf4l\n%s\n" "$SRC_LINE" >> "$RC_FILE"
    echo "Added ctf4l to $RC_FILE"
  else
    echo "ctf4l already present in $RC_FILE"
  fi

  echo "Done. Restart your shell, or run: source \"$RC_FILE\""
}

main "$@"
