#!/usr/bin/env bash
set -euo pipefail

detect_shell() {
  if [ -n "${ZSH_VERSION:-}" ]; then
    SHELL_NAME="zsh"; RC_FILE="$HOME/.zshrc"
  elif [ -n "${BASH_VERSION:-}" ]; then
    SHELL_NAME="bash"; RC_FILE="$HOME/.bashrc"
  else
    case "$(basename "${SHELL:-}")" in
      zsh) SHELL_NAME="zsh"; RC_FILE="$HOME/.zshrc" ;;
      bash) SHELL_NAME="bash"; RC_FILE="$HOME/.bashrc" ;;
      *) SHELL_NAME="bash"; RC_FILE="$HOME/.bashrc" ;;
    esac
  fi
}

main() {
  detect_shell
  echo "Removing ctf4l from $RC_FILE and ~/.ctf4l/"
  tmp="$(mktemp)"
  if [ "$SHELL_NAME" = "zsh" ]; then
    sed '/^# ctf4l$/,/^source \$HOME\/\.ctf4l\/ctf4l\.zsh$/d' "$RC_FILE" > "$tmp" || true
  else
    sed '/^# ctf4l$/,/^source \$HOME\/\.ctf4l\/ctf4l\.bash$/d' "$RC_FILE" > "$tmp" || true
  fi
  mv "$tmp" "$RC_FILE"
  rm -rf "$HOME/.ctf4l"
  echo "Uninstalled. Restart your shell."
}

main "$@"
