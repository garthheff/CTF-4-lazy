# Load vars
[[ -f ~/.cmdvars ]] && source ~/.cmdvars

# Expand lines from ~/.cmdlist with current env (IP, WORDLIST, etc.)
_ctf4l_expand_cmdlist() {
  [[ -f ~/.cmdlist ]] || return
  local line
  while IFS= read -r line; do
    eval "print -r -- \"$line\""
  done < ~/.cmdlist
}

# ZLE widget: prefilter by what’s already typed, show fzf, insert full command
ctf4l() {
  local left="$LBUFFER"
  local query="$left"

  # if user typed 'ctf4l something', strip it from prefilter
  if [[ "$left" == ctf4l* ]]; then
    query="${left#ctf4l }"
  fi
  query="${query## }"

  local list sel
  list=$(_ctf4l_expand_cmdlist)

  # strict substring prefilter (fallback to full list if no matches)
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

# Key binding: Alt+c
bindkey '^[c' ctf4l

# Helpers
setip() {
  [[ -z "$1" ]] && { echo "Usage: setip <ip>"; return 1; }
  [[ -f ~/.cmdvars ]] || : > ~/.cmdvars
  grep -v '^export IP=' ~/.cmdvars > ~/.cmdvars.tmp 2>/dev/null || true
  mv ~/.cmdvars.tmp ~/.cmdvars
  print -r -- "export IP=$1" >> ~/.cmdvars
  export IP="$1"
  echo "IP set to $IP"
}
setwordlist() {
  [[ -z "$1" ]] && { echo "Usage: setwordlist <path>"; return 1; }
  [[ -f ~/.cmdvars ]] || : > ~/.cmdvars
  grep -v '^export WORDLIST=' ~/.cmdvars > ~/.cmdvars.tmp 2>/dev/null || true
  mv ~/.cmdvars.tmp ~/.cmdvars
  print -r -- "export WORDLIST=$1" >> ~/.cmdvars
  export WORDLIST="$1"
  echo "WORDLIST set to $WORDLIST"
}
