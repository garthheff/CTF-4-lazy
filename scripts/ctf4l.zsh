# Load vars from ~/.cmdvars and any drop-ins in ~/.cmdvars.d/*.env
if [[ -f "$HOME/.cmdvars" ]]; then
  source "$HOME/.cmdvars"
fi
if [[ -d "$HOME/.cmdvars.d" ]]; then
  for f in "$HOME"/.cmdvars.d/*.env; do
    [[ -f "$f" ]] && source "$f"
  done
fi

# Expand lines from ~/.cmdlist using current env (IP, WORDLIST, and any others)
_ctf4l_expand_cmdlist() {
  [[ -f "$HOME/.cmdlist" ]] || return
  local line
  while IFS= read -r line; do
    # Expand variables safely; keep original text form
    eval "print -r -- \"$line\""
  done < "$HOME/.cmdlist"
}

# ZLE widget: prefilter by what's typed, open fzf, insert full command
ctf4l() {
  local left="$LBUFFER"
  local query="$left"

  # If user typed 'ctf4l ' at the start, strip it from prefilter
  if [[ "$left" == ctf4l* ]]; then
    query="${left#ctf4l }"
  fi
  query="${query## }"

  local list sel
  list=$(_ctf4l_expand_cmdlist)

  # strict substring prefilter; fall back to full list if no match
  if [[ -n "$query" ]]; then
    list=$(print -r -- "$list" | grep -i -- "$query" 2>/dev/null)
    [[ -z "$list" ]] && list=$(_ctf4l_expand_cmdlist)
  fi

  sel=$(print -r -- "$list" | fzf --height=40% --query="$query") || return

  LBUFFER="$sel"
  RBUFFER=""
  zle redisplay
}
zle -N ctf4l

# Default key bind: Alt+c
bindkey '^[c' ctf4l
# If you *want* Tab instead (overrides normal completion):
# bindkey '^I' ctf4l

# ---- Helpers ----

# setip 1.2.3.4
setip() {
  [[ -n "$1" ]] || { echo "Usage: setip <ip>"; return 1 }
  [[ -f "$HOME/.cmdvars" ]] || : > "$HOME/.cmdvars"
  grep -v '^export IP=' "$HOME/.cmdvars" > "$HOME/.cmdvars.tmp" 2>/dev/null || true
  mv "$HOME/.cmdvars.tmp" "$HOME/.cmdvars"
  print -r -- "export IP=$1" >> "$HOME/.cmdvars"
  export IP="$1"
  echo "IP set to $IP"
}

# setwordlist /path/to/wordlist
setwordlist() {
  [[ -n "$1" ]] || { echo "Usage: setwordlist <path>"; return 1 }
  [[ -f "$HOME/.cmdvars" ]] || : > "$HOME/.cmdvars"
  grep -v '^export WORDLIST=' "$HOME/.cmdvars" > "$HOME/.cmdvars.tmp" 2>/dev/null || true
  mv "$HOME/.cmdvars.tmp" "$HOME/.cmdvars"
  print -r -- "export WORDLIST=$1" >> "$HOME/.cmdvars"
  export WORDLIST="$1"
  echo "WORDLIST set to $WORDLIST"
}

# setvar NAME VALUE   (generic)
setvar() {
  [[ -n "$1" && -n "$2" ]] || { echo "Usage: setvar NAME VALUE"; return 1 }
  [[ -f "$HOME/.cmdvars" ]] || : > "$HOME/.cmdvars"
  grep -v "^export $1=" "$HOME/.cmdvars" > "$HOME/.cmdvars.tmp" 2>/dev/null || true
  mv "$HOME/.cmdvars.tmp" "$HOME/.cmdvars"
  print -r -- "export $1=$2" >> "$HOME/.cmdvars"
  export "$1=$2"
  echo "$1 set to ${parameters[$1]}"
}

# unsetvar NAME
unsetvar() {
  [[ -n "$1" ]] || { echo "Usage: unsetvar NAME"; return 1 }
  [[ -f "$HOME/.cmdvars" ]] || return 0
  grep -v "^export $1=" "$HOME/.cmdvars" > "$HOME/.cmdvars.tmp" 2>/dev/null || true
  mv "$HOME/.cmdvars.tmp" "$HOME/.cmdvars"
  unset "$1"
  echo "$1 unset"
}

# listvars  (shows exported vars managed by ctf4l)
listvars() {
  if [[ -f "$HOME/.cmdvars" ]]; then
    awk -F'=' '/^export /{print $1"="$2}' "$HOME/.cmdvars"
  else
    echo "(no vars yet)"
  fi
}

# Profiles: savevars <name>, loadvars <name>
savevars() {
  [[ -n "$1" ]] || { echo "Usage: savevars <profilename>"; return 1 }
  [[ -f "$HOME/.cmdvars" ]] || { echo "No ~/.cmdvars to save"; return 1 }
  mkdir -p "$HOME/.cmdvars.d"
  cp "$HOME/.cmdvars" "$HOME/.cmdvars.d/$1.env"
  echo "Saved to ~/.cmdvars.d/$1.env"
}

loadvars() {
  [[ -n "$1" ]] || { echo "Usage: loadvars <profilename>"; return 1 }
  [[ -f "$HOME/.cmdvars.d/$1.env" ]] || { echo "No such profile: $1"; return 1 }
  cp "$HOME/.cmdvars.d/$1.env" "$HOME/.cmdvars"
  # shellcheck disable=SC1090
  source "$HOME/.cmdvars"
  echo "Loaded $1"
}
