# CTF-4-lazy
ctf4l — Bash/Zsh helper for CTFs &amp; sysadmins. Define full command templates with variables (e.g. $IP, $WORDLIST) and launch them via an fzf autocomplete menu. Live filter as you type, insert the expanded command into your prompt, and update variables anytime with setip / setwordlist.

## Requirements
- [`fzf`](https://github.com/junegunn/fzf)

### Install fzf
**Debian/Ubuntu/Kali**
* sudo apt update
* sudo apt install -y fzf

## Install CTF-4-lazy
* git clone https://github.com/garthheff/CTF-4-lazy/ctf4l.git
* cd ctf4l
* ./install.sh

## restart your shell or: source ~/.zshrc  or ~/.bashrc
[ -n "$ZSH_VERSION" ] && source ~/.zshrc || { [ -n "$BASH_VERSION" ] && source ~/.bashrc; }

## Usage

### After installation, you get:

* Alt+c → open fzf menu of commands (~/.cmdlist) expanded with your current $IP and $WORDLIST.
* setip <ip> → update the target IP in ~/.cmdvars.
* setwordlist <path> → update the wordlist in ~/.cmdvars.

### Examples:
* setip 10.10.20.5
* setwordlist /usr/share/wordlists/rockyou.txt
* ctf4l (Alt+c → open fzf menu of commands)
