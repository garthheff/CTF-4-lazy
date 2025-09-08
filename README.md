# CTF-4-lazy
ctf4l — Bash/Zsh helper for CTFs &amp; sysadmins. Define full command templates with variables (e.g. $IP, $WORDLIST) and launch them via an fzf autocomplete menu. Live filter as you type, insert the expanded command into your prompt, and update variables anytime with setip / setwordlist.

<img width="1292" height="726" alt="image" src="https://github.com/user-attachments/assets/da7deaf3-39b9-4861-980f-e10102e6222d" />

## Requirements (Dependencies)
- [`fzf`](https://github.com/junegunn/fzf)
- [`envsubst`](https://www.gnu.org/software/gettext/manual/html_node/envsubst-Invocation.html) (part of **gettext**) – expands variables in your command templates while preserving quotes  

### Install fzf
**Debian/Ubuntu/Kali**
* sudo apt update
* sudo apt install -y fzf

### Install gettext-base
**Debian/Ubuntu/Kali**
* sudo apt update
* sudo apt install -y fzf gettext-base

## Install CTF-4-lazy
* git clone https://github.com/garthheff/CTF-4-lazy.git
* cd CTF-4-lazy
* chmod +x install.sh
* ./install.sh

## restart your shell or: source ~/.zshrc  or ~/.bashrc
[ -n "$ZSH_VERSION" ] && source ~/.zshrc || { [ -n "$BASH_VERSION" ] && source ~/.bashrc; }

## Usage
Usage

### After installation, you get:

* Alt+c → open the fzf menu of commands from ~/.cmdlist (expanded with variables from ~/.cmdvars / ~/.cmdvars.d).
* setip <ip> → update the target IP in ~/.cmdvars.
* setwordlist <path> → update the wordlist in ~/.cmdvars.
* setvar NAME VALUE → set any custom variable (e.g., setvar THREADS 64, setvar AGENT "Mozilla/5.0").
* unsetvar NAME → remove a variable.
* listvars → list all currently defined variables.
* savevars NAME / loadvars NAME → save and switch between variable profiles (~/.cmdvars.d/NAME.env).

Variables can be used in your command list (~/.cmdlist) with $NAME or ${NAME} and are expanded with envsubst, so quotes and special characters are preserved.

### Examples:
#### set variables
```
setip 10.10.20.5
* setwordlist /usr/share/wordlists/rockyou.txt
* setvar THREADS 64
* setvar AGENT "Mozilla/5.0"
```

#### Open the menu and pick a command (Alt+c)

__To list all commands__
```
ctf4l
```
__To list all commands that start with e.g gobuster__
```
ctf4l gobuster
```

#### Variable Expansion Rules (envsubst)

The command list (~/.cmdlist) is expanded using envsubst

#### This means:✅ Expanded:
* $VAR
* ${VAR}

#### ❌ Not expanded (remain literal):
* $1, $2 … (positional parameters)
* ${VAR:-default} (default values)
* $(command) (command substitution)
* Backslashes, wildcards (*), pipes, etc.

#### Escaping
If you want to keep a literal $VAR in your command (no expansion), escape the $:
```
echo \$IP
```

#### After expansion:
```
echo $IP
```

#### Example
```
~/.cmdvars:
export IP=10.10.20.5
export AGENT="Mozilla/5.0"
```

#### ~/.cmdlist:
```
curl -H "User-Agent: $AGENT" http://$IP/
echo \$IP   # literal string
```

#### Expands to:
```
curl -H "User-Agent: Mozilla/5.0" http://10.10.20.5/
echo $IP
```
