# ~/.zshrc

# ─────────────────────────────────────────
# OH MY ZSH
# ─────────────────────────────────────────
export ZSH="$HOME/.oh-my-zsh"

# Set theme to nothing — Starship handles prompt
ZSH_THEME=""

# Plugins
plugins=(
  git                       # git aliases and completions
  asdf                      # asdf completions
  macos                     # Mac specific utilities
  docker                    # docker completions (works with podman)
  kubectl                   # kubectl completions + aliases
  golang                    # go aliases
  node                      # node aliases
  python                    # python aliases
  ruby                      # ruby aliases
  rust                      # rust completions
  brew                      # brew completions
  vscode                    # vs code helpers
  terraform                 # terraform completions
  aws                       # aws completions
  gh                        # github cli completions
  zsh-autosuggestions       # fish-like suggestions
  zsh-syntax-highlighting   # syntax highlighting
  zsh-completions           # extra completions
  fzf                       # fuzzy finder integration
  z                         # zoxide alternative (built-in)
)

source $ZSH/oh-my-zsh.sh


# ─────────────────────────────────────────
# HOMEBREW
# ─────────────────────────────────────────
eval "$(/opt/homebrew/bin/brew shellenv)"  # Apple Silicon
# eval "$(/usr/local/bin/brew shellenv)"   # Intel


# ─────────────────────────────────────────
# ASDF
# ─────────────────────────────────────────
. /opt/homebrew/opt/asdf/libexec/asdf.sh


# ─────────────────────────────────────────
# STARSHIP PROMPT
# (must be after oh-my-zsh)
# ─────────────────────────────────────────
eval "$(starship init zsh)"


# ─────────────────────────────────────────
# BETTER TOOLS
# ─────────────────────────────────────────
# lsd
alias ls="lsd"
alias ll="lsd -la"
alias lt="lsd --tree"
alias la="lsd -A"

# zoxide
eval "$(zoxide init zsh)"
alias cd="z"

# thefuck
eval "$(thefuck --alias)"

# btop
alias top="btop"

# lazygit
alias lg="lazygit"


# ─────────────────────────────────────────
# HISTORY
# ─────────────────────────────────────────
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY


# ─────────────────────────────────────────
# ALIASES — Navigation
# ─────────────────────────────────────────
alias ..="cd .."
alias ...="cd ../.."
alias ~="cd ~"


# ─────────────────────────────────────────
# ALIASES — Git
# ─────────────────────────────────────────
alias g="git"
alias gs="git status"
alias ga="git add"
alias gc="git commit -m"
alias gp="git push"
alias gl="git pull"
alias glog="git log --oneline --graph --decorate"
alias gco="git checkout"
alias gb="git branch"


# ─────────────────────────────────────────
# ALIASES — Homebrew
# ─────────────────────────────────────────
alias brewup="brew update && brew upgrade && brew cleanup"
alias brewdump="brew bundle dump --file=~/.dotfiles/Brewfile --force"


# ─────────────────────────────────────────
# ALIASES — System
# ─────────────────────────────────────────
alias reload="source ~/.zshrc"
alias zshrc="code ~/.zshrc"
alias dotfiles="cd ~/.dotfiles"
alias ip="curl ifconfig.me"
alias localip="ipconfig getifaddr en0"
alias flushdns="sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder"


# ─────────────────────────────────────────
# PODMAN (docker alias)
# ─────────────────────────────────────────
alias docker="podman"
alias docker-compose="podman-compose"


# ─────────────────────────────────────────
# EDITOR
# ─────────────────────────────────────────
export EDITOR="code --wait"


# ─────────────────────────────────────────
# LANGUAGE / LOCALE
# ─────────────────────────────────────────
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"


# ─────────────────────────────────────────
# FUNCTIONS
# ─────────────────────────────────────────

# Make dir and cd into it
mkcd() { mkdir -p "$1" && cd "$1"; }

# Find file by name
ff() { find . -name "*$1*" 2>/dev/null; }

# Extract any archive
extract() {
  case "$1" in
    *.tar.gz)  tar -xzf "$1"  ;;
    *.tar.bz2) tar -xjf "$1"  ;;
    *.zip)     unzip "$1"      ;;
    *.gz)      gunzip "$1"     ;;
    *.rar)     unrar x "$1"    ;;
    *)         echo "Unknown format: $1" ;;
  esac
}

# Show all asdf versions at once
versions() { asdf current; }

# Quick git commit + push
gacp() { git add -A && git commit -m "$1" && git push; }
