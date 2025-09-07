# Load vars
[[ -f ~/.cmdvars ]] && source ~/.cmdvars

# Expand lines from ~/.cmdlist with current env (IP, WORDLIST, etc.)
_ctf4l_expand_cmdlist() {
  [[ -f ~/.cmdlist ]] || return
  while IFS= read -r line; do
    eval "printf '%s\n' \"$line\""
  done < ~/.cmdlist
}

# Bash readline widget via bind -x (Alt+c)
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

# Key binding: Alt+c
bind -x '"\ec":ctf4l'

# Helpers
setip() {
  if [[ -z "$1" ]]; then echo "Usage: setip <ip>"; return 1; fi
  [[ -f ~/.cmdvars ]] || : > ~/.cmdvars
  grep -v '^export IP=' ~/.cmdvars > ~/.cmdvars.tmp 2>/dev/null || true
  mv ~/.cmdvars.tmp ~/.cmdvars
  printf 'export IP=%s\n' "$1" >> ~/.cmdvars
  export IP="$1"
  echo "IP set to $IP"
}
setwordlist() {
  if [[ -z "$1" ]]; then echo "Usage: setwordlist <path>"; return 1; fi
  [[ -f ~/.cmdvars ]] || : > ~/.cmdvars
  grep -v '^export WORDLIST=' ~/.cmdvars > ~/.cmdvars.tmp 2>/dev/null || true
  mv ~/.cmdvars.tmp ~/.cmdvars
  printf 'export WORDLIST=%s\n' "$1" >> ~/.cmdvars
  export WORDLIST="$1"
  echo "WORDLIST set to $WORDLIST"
}
