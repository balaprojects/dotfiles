# ~/.dotfiles/Brewfile

# Note: homebrew/cask-fonts tap was deprecated — fonts now in Homebrew core directly


# ─────────────────────────────────────────
# CORE CLI TOOLS
# ─────────────────────────────────────────
brew "git"
brew "curl"
brew "wget"
brew "jq"              # JSON processor
brew "yq"              # YAML processor
brew "tree"            # directory tree view
brew "ripgrep"         # fast search (rg)
brew "fd"              # fast find alternative
brew "bat"             # better cat with syntax highlighting
brew "fzf"             # fuzzy finder
brew "zsh-autosuggestions"
brew "zsh-syntax-highlighting"
brew "mas"             # Mac App Store CLI — required for mas installs
brew "uv"


# ─────────────────────────────────────────
# GIT TOOLS
# ─────────────────────────────────────────
brew "gh"              # GitHub CLI
brew "git-delta"       # better git diff
cask "copilot-cli"        # GitHub Copilot in the terminal


# ─────────────────────────────────────────
# ASDF — Universal Version Manager
# (replaces nvm, pyenv, rbenv, sdkman etc.)
# ─────────────────────────────────────────
brew "asdf"
brew "gpg"             # needed for some asdf plugins
brew "gawk"            # needed for some asdf plugins


# ─────────────────────────────────────────
# LANGUAGE DEPENDENCIES
# (asdf compiles from source, needs these)
# ─────────────────────────────────────────

# Node
brew "openssl"

# Python
brew "readline"
brew "sqlite3"
brew "xz"
brew "zlib"
brew "tcl-tk"

# Ruby
brew "libyaml"

# Java
brew "coursier"        # Scala installer

# Erlang/Elixir
brew "autoconf"
brew "wxwidgets"


# ─────────────────────────────────────────
# INFRASTRUCTURE / DEVOPS
# ─────────────────────────────────────────
brew "podman"                  # Docker alternative
brew "podman-compose"          # docker-compose alternative
brew "kubernetes-cli"          # kubectl
brew "helm"                    # Kubernetes package manager
brew "awscli"                  # AWS CLI
brew "azure-cli"               # Azure CLI


# ─────────────────────────────────────────
# DATABASE CLIENTS (CLI)
# ─────────────────────────────────────────
brew "postgresql@16"           # psql client
brew "mysql-client"            # mysql client
brew "mongosh"                 # MongoDB shell
brew "redis"                   # redis-cli


# ─────────────────────────────────────────
# API / NETWORKING
# ─────────────────────────────────────────
brew "httpie"                  # better curl for APIs
brew "grpcurl"                 # gRPC client
brew "mkcert"                  # local HTTPS certificates


# ─────────────────────────────────────────
# SECURITY & PRIVACY (all free & open source)
# ─────────────────────────────────────────
brew "gnupg"                   # GPG CLI tools
brew "age"                     # simple modern file encryption
cask "bitwarden"               # open source password manager
cask "lulu"                    # open source outgoing firewall
cask "oversight"               # alerts when mic/camera activated
cask "knockknock"              # audit what runs persistently
cask "blockblock"              # monitor persistent background installs
cask "gpg-suite"               # GPG for files and git commit signing


# ─────────────────────────────────────────
# TERMINAL CUSTOMIZATION
# ─────────────────────────────────────────
brew "starship"              # fast cross-shell prompt
brew "lsd"                   # better ls with icons
brew "zoxide"                # smarter cd (remembers dirs)
brew "thefuck"               # correct mistyped commands
brew "btop"                  # beautiful system monitor
brew "lazygit"               # terminal UI for git

# Terminal Emulator
cask "iterm2"                # feature-rich terminal
cask "warp"                  # AI-powered modern terminal


# ─────────────────────────────────────────
# GUI APPS (Casks)
# ─────────────────────────────────────────

# Development
cask "visual-studio-code"
cask "intellij-idea"           # IntelliJ IDEA
cask "podman-desktop"          # Podman GUI
cask "responsively"            # responsive design testing
cask "insomnia"                # REST/GraphQL API client (free)
cask "ngrok"                   # expose localhost to internet

# Database GUIs
cask "tableplus"               # MySQL, Postgres, Redis, Mongo (paid)
cask "beekeeper-studio"        # open source DB GUI (free alternative)
cask "another-redis-desktop-manager"  # free Redis GUI
cask "mongodb-compass"         # MongoDB GUI

# API Testing
cask "bruno"                   # open source Postman alternative

# Productivity
cask "rectangle"               # window manager
cask "raycast"                 # better Spotlight
cask "microsoft-teams"         # Microsoft Teams
cask "microsoft-outlook"       # Microsoft Outlook
cask "zoom"                    # Video conferencing

# Menu Bar (all free)
cask "stats"                   # CPU, RAM, network, disk in menu bar
cask "hiddenbar"               # hide unused menu bar icons
cask "keepingyouawake"         # keep Mac awake (open source)
# Note: Clocker (multiple time zones in menu bar) is installed via Mac App Store below

# Browser
cask "arc"                     # best browser for developers (free)
cask "firefox"
cask "google-chrome"

# File Management (free)
cask "the-unarchiver"          # open any zip/rar/7z format
cask "cyberduck"               # FTP/SFTP/S3 client
cask "imageoptim"              # compress images without quality loss

# Media (free)
cask "vlc"                     # play any video format
cask "iina"                    # modern native video player for Mac

# Notes (free & open source)
cask "obsidian"                # markdown notes, local, offline

# Fonts (for dev)
cask "font-jetbrains-mono-nerd-font"   # for terminal (with icons)
cask "font-jetbrains-mono"             # for VS Code (clean version)
cask "font-fira-code-nerd-font"        # alternative with ligatures


# ─────────────────────────────────────────
# MAC APP STORE
# ─────────────────────────────────────────
mas "Amphetamine", id: 937984704       # keep Mac awake
mas "Clocker", id: 1056643111          # multiple time zones in menu bar
