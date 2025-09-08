# Load vars from ~/.cmdvars and any drop-ins in ~/.cmdvars.d/*.env
[[ -f "$HOME/.cmdvars" ]] && . "$HOME/.cmdvars"
if [[ -d "$HOME/.cmdvars.d" ]]; then
  for f in "$HOME"/.cmdvars.d/*.env; do
    [[ -f "$f" ]] && . "$f"
  done
fi

# Expand lines from ~/.cmdlist using envsubst (preserves quotes)
_ctf4l_expand_cmdlist() {
  [[ -f "$HOME/.cmdlist" ]] || return
  if command -v envsubst >/dev/null 2>&1; then
    while IFS= read -r line; do
      printf '%s\n' "$line" | envsubst
    done < "$HOME/.cmdlist"
  else
    # Fallback (warn + best-effort expansion)
    printf '%s\n' "(warning) envsubst not found; quotes may not be preserved"
    while IFS= read -r line; do
      # Minimal fallback: expand vars with parameter expansion, keep quotes literal
      eval "printf '%s\n' \"${line//\\/\\\\}\""
    done < "$HOME/.cmdlist"
  fi
}

# Readline-bound function: prefilter by current line, open fzf, insert command
ctf4l() {
  local left="${READLINE_LINE:0:READLINE_POINT}"
  local query="$left"
  if [[ "$left" == ctf4l\ * ]]; then
    query="${left#ctf4l }"
  fi

  local list sel
  list="$(_ctf4l_expand_cmdlist)"

  if [[ -n "$query" ]]; then
    list="$(printf '%s\n' "$list" | grep -i -- "$query" || true)"
    [[ -z "$list" ]] && list="$(_ctf4l_expand_cmdlist)"
  fi

  sel="$(printf '%s\n' "$list" | fzf --height=40% --query="$query")" || return

  READLINE_LINE="$sel"
  READLINE_POINT=${#READLINE_LINE}
}

# Default key bind: Alt+c
bind -x '"\ec":ctf4l'
# If you *want* Tab instead (overrides normal completion):
# bind -x '"\t":ctf4l'

# ---- Helpers ----

# setip 1.2.3.4
setip() {
  if [[ -z "$1" ]]; then echo "Usage: setip <ip>"; return 1; fi
  [[ -f "$HOME/.cmdvars" ]] || : > "$HOME/.cmdvars"
  grep -v '^export IP=' "$HOME/.cmdvars" > "$HOME/.cmdvars.tmp" 2>/dev/null || true
  mv "$HOME/.cmdvars.tmp" "$HOME/.cmdvars"
  printf 'export IP=%s\n' "$1" >> "$HOME/.cmdvars"
  export IP="$1"
  echo "IP set to $IP"
}

# setwordlist /path/to/wordlist
setwordlist() {
  if [[ -z "$1" ]]; then echo "Usage: setwordlist <path>"; return 1; fi
  [[ -f "$HOME/.cmdvars" ]] || : > "$HOME/.cmdvars"
  grep -v '^export WORDLIST=' "$HOME/.cmdvars" > "$HOME/.cmdvars.tmp" 2>/dev/null || true
  mv "$HOME/.cmdvars.tmp" "$HOME/.cmdvars"
  printf 'export WORDLIST=%s\n' "$1" >> "$HOME/.cmdvars"
  export WORDLIST="$1"
  echo "WORDLIST set to $WORDLIST"
}

# setvar NAME VALUE   (generic)
setvar() {
  if [[ -z "$1" || -z "$2" ]]; then echo "Usage: setvar NAME VALUE"; return 1; fi
  [[ -f "$HOME/.cmdvars" ]] || : > "$HOME/.cmdvars"
  grep -v "^export $1=" "$HOME/.cmdvars" > "$HOME/.cmdvars.tmp" 2>/dev/null || true
  mv "$HOME/.cmdvars.tmp" "$HOME/.cmdvars"
  printf 'export %s=%s\n' "$1" "$2" >> "$HOME/.cmdvars"
  export "$1=$2"
  eval "echo \"$1 set to \$$1\""
}

# unsetvar NAME
unsetvar() {
  if [[ -z "$1" ]]; then echo "Usage: unsetvar NAME"; return 1; fi
  [[ -f "$HOME/.cmdvars" ]] || return 0
  grep -v "^export $1=" "$HOME/.cmdvars" > "$HOME/.cmdvars.tmp" 2>/dev/null || true
  mv "$HOME/.cmdvars.tmp" "$HOME/.cmdvars"
  unset "$1"
  echo "$1 unset"
}

# listvars
listvars() {
  if [[ -f "$HOME/.cmdvars" ]]; then
    awk -F'=' '/^export /{print $1"="$2}' "$HOME/.cmdvars"
  else
    echo "(no vars yet)"
  fi
}

# Profiles
savevars() {
  if [[ -z "$1" ]]; then echo "Usage: savevars <profilename>"; return 1; fi
  [[ -f "$HOME/.cmdvars" ]] || { echo "No ~/.cmdvars to save"; return 1; }
  mkdir -p "$HOME/.cmdvars.d"
  cp "$HOME/.cmdvars" "$HOME/.cmdvars.d/$1.env"
  echo "Saved to ~/.cmdvars.d/$1.env"
}

loadvars() {
  if [[ -z "$1" ]]; then echo "Usage: loadvars <profilename>"; return 1; fi
  [[ -f "$HOME/.cmdvars.d/$1.env" ]] || { echo "No such profile: $1"; return 1; }
  cp "$HOME/.cmdvars.d/$1.env" "$HOME/.cmdvars"
  . "$HOME/.cmdvars"
  echo "Loaded $1"
}
