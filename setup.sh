#!/bin/bash
# ~/.dotfiles/setup.sh

set -e  # Exit on any error

# ─────────────────────────────────────────
# COLORS FOR OUTPUT
# ─────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

log()     { echo -e "${BLUE}==>${NC} $1"; }
success() { echo -e "${GREEN}✓${NC} $1"; }
warn()    { echo -e "${YELLOW}!${NC} $1"; }
error()   { echo -e "${RED}✗${NC} $1"; exit 1; }


# ─────────────────────────────────────────
# 1. HOMEBREW
# ─────────────────────────────────────────
log "Checking Homebrew..."

if ! command -v brew &>/dev/null; then
  log "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Add Homebrew to PATH immediately
  if [[ $(uname -m) == "arm64" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  else
    eval "$(/usr/local/bin/brew shellenv)"
  fi
  success "Homebrew installed"
else
  success "Homebrew already installed"
fi


# ─────────────────────────────────────────
# 2. INSTALL FROM BREWFILE
# ─────────────────────────────────────────
log "Installing packages from Brewfile..."
brew bundle --file=~/.dotfiles/Brewfile
success "Brewfile packages installed"


# ─────────────────────────────────────────
# 3. SYMLINK DOTFILES
# ─────────────────────────────────────────
log "Symlinking dotfiles..."

symlink() {
  local src=$1
  local dst=$2
  if [ -f "$dst" ] && [ ! -L "$dst" ]; then
    warn "Backing up existing $dst to $dst.bak"
    mv "$dst" "$dst.bak"
  fi
  ln -sf "$src" "$dst"
  success "Linked $dst"
}

symlink ~/.dotfiles/.zshrc       ~/.zshrc
symlink ~/.dotfiles/.gitconfig   ~/.gitconfig
symlink ~/.dotfiles/Brewfile     ~/.Brewfile
symlink ~/.dotfiles/vscode/settings.json \
  "$HOME/Library/Application Support/Code/User/settings.json"


# ─────────────────────────────────────────
# STARSHIP CONFIG
# ─────────────────────────────────────────
log "Setting up Starship config..."
mkdir -p ~/.config
symlink ~/.dotfiles/starship.toml ~/.config/starship.toml
success "Starship config linked"

# ─────────────────────────────────────────
# OH MY ZSH
# ─────────────────────────────────────────
log "Installing Oh My Zsh..."

if [ -d "$HOME/.oh-my-zsh" ]; then
  warn "Oh My Zsh already installed, skipping"
else
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
    "" --unattended
  success "Oh My Zsh installed"
fi

# Install plugins
log "Installing Oh My Zsh plugins..."

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

clone_plugin() {
  local repo=$1
  local dir=$2
  if [ -d "$dir" ]; then
    warn "Plugin already exists: $dir"
  else
    git clone "$repo" "$dir"
    success "Cloned plugin: $dir"
  fi
}

clone_plugin \
  https://github.com/zsh-users/zsh-autosuggestions \
  $ZSH_CUSTOM/plugins/zsh-autosuggestions

clone_plugin \
  https://github.com/zsh-users/zsh-syntax-highlighting \
  $ZSH_CUSTOM/plugins/zsh-syntax-highlighting

clone_plugin \
  https://github.com/zsh-users/zsh-completions \
  $ZSH_CUSTOM/plugins/zsh-completions


# ─────────────────────────────────────────
# 4. ASDF — SETUP
# ─────────────────────────────────────────
log "Setting up asdf..."

# Add asdf to current shell session
if [[ $(uname -m) == "arm64" ]]; then
  ASDF_PATH="/opt/homebrew/opt/asdf/libexec/asdf.sh"
else
  ASDF_PATH="/usr/local/opt/asdf/libexec/asdf.sh"
fi

if [ -f "$ASDF_PATH" ]; then
  . "$ASDF_PATH"
  success "asdf loaded"
else
  error "asdf not found — check Brewfile installation"
fi


# ─────────────────────────────────────────
# 5. ASDF — INSTALL PLUGINS
# ─────────────────────────────────────────
log "Installing asdf plugins..."

install_plugin() {
  local plugin=$1
  if asdf plugin list | grep -q "^$plugin$"; then
    warn "Plugin '$plugin' already installed, skipping"
  else
    asdf plugin add "$plugin"
    success "Plugin '$plugin' added"
  fi
}

install_plugin nodejs
install_plugin python
install_plugin ruby
install_plugin java
install_plugin golang
install_plugin rust
install_plugin elixir
install_plugin erlang


# ─────────────────────────────────────────
# 6. ASDF — INSTALL RUNTIMES
# ─────────────────────────────────────────
log "Installing language runtimes..."

install_runtime() {
  local lang=$1
  local version=$2
  if asdf list "$lang" 2>/dev/null | grep -q "$version"; then
    warn "$lang $version already installed, skipping"
  else
    log "Installing $lang $version..."
    asdf install "$lang" "$version"
    success "$lang $version installed"
  fi
}

install_runtime nodejs   latest
install_runtime python   latest
install_runtime ruby     latest
install_runtime java     latest:temurin-21
install_runtime golang   latest
install_runtime rust     latest
install_runtime elixir   latest
install_runtime erlang   latest


# ─────────────────────────────────────────
# 7. ASDF — SET GLOBAL VERSIONS
# ─────────────────────────────────────────
log "Setting global runtime versions..."

asdf global nodejs  latest
asdf global python  latest
asdf global ruby    latest
asdf global java    latest:temurin-21
asdf global golang  latest
asdf global rust    latest
asdf global elixir  latest
asdf global erlang  latest

success "Global versions set"


# ─────────────────────────────────────────
# 8. PODMAN SETUP
# ─────────────────────────────────────────
log "Setting up Podman..."

if podman machine list 2>/dev/null | grep -q "Currently running"; then
  warn "Podman machine already running, skipping"
else
  podman machine init
  podman machine start
  success "Podman machine started"
fi


# ─────────────────────────────────────────
# 9. VSCODE EXTENSIONS
# ─────────────────────────────────────────
log "Installing VS Code extensions..."

if command -v code &>/dev/null; then
  extensions=(
    # General
    "eamodio.gitlens"
    "github.copilot"
    "streetsidesoftware.code-spell-checker"
    "christian-kohler.path-intellisense"
    "usernamehw.errorlens"

    # Language support
    "dbaeumer.vscode-eslint"
    "esbenp.prettier-vscode"
    "ms-python.python"
    "golang.go"
    "rust-lang.rust-analyzer"
    "rebornix.ruby"
    "jakebecker.elixir-ls"

    # Containers
    "ms-azuretools.vscode-docker"

    # DB
    "mtxr.sqltools"

    # Themes & UI
    "pkief.material-icon-theme"
    "zhuangtongfa.material-theme"
  )

  for ext in "${extensions[@]}"; do
    code --install-extension "$ext" --force &>/dev/null
    success "Installed VS Code extension: $ext"
  done
else
  warn "VS Code CLI not found — install extensions manually"
fi


# ─────────────────────────────────────────
# 10. APPLY SHELL CONFIG
# ─────────────────────────────────────────
log "Applying shell config..."
source ~/.zshrc 2>/dev/null || warn "Run 'source ~/.zshrc' manually after setup"


# ─────────────────────────────────────────
# DONE
# ─────────────────────────────────────────
echo ""
echo -e "${GREEN}✓ Setup complete!${NC}"
echo ""
echo "Next steps:"
echo "  1. Run: source ~/.zshrc"
echo "  2. Verify: asdf current"
echo "  3. Verify: podman run hello-world"
echo "  4. Open VS Code and sign in to GitHub Copilot"
