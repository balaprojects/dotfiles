#!/bin/bash
# ~/.dotfiles/setup.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ─────────────────────────────────────────
# COLORS & HELPERS
# ─────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

log()     { echo -e "\n${BLUE}${BOLD}==>${NC} ${BOLD}$1${NC}"; }
success() { echo -e "  ${GREEN}✓${NC} $1"; }
warn()    { echo -e "  ${YELLOW}!${NC} $1"; }
error()   { echo -e "  ${RED}✗${NC} $1"; }
info()    { echo -e "  ${CYAN}→${NC} $1"; }

ERRORS=()
fail() { ERRORS+=("$1"); error "$1"; }

START_TIME=$SECONDS
elapsed() { echo $(( SECONDS - START_TIME )); }
divider() { echo -e "\n${BOLD}────────────────────────────────────────${NC}"; }


# ─────────────────────────────────────────
# HEADER
# ─────────────────────────────────────────
clear
echo -e "${BOLD}${BLUE}"
echo "  ██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗███████╗"
echo "  ██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝██╔════╝"
echo "  ██║  ██║██║   ██║   ██║   █████╗  ██║██║     █████╗  ███████╗"
echo "  ██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝  ╚════██║"
echo "  ██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗███████║"
echo "  ╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝"
echo -e "${NC}"
echo -e "  ${BOLD}Mac Developer Setup Script${NC}"
echo -e "  Starting at $(date '+%H:%M:%S')\n"
divider


# ─────────────────────────────────────────
# 1. HOMEBREW
# ─────────────────────────────────────────
log "STEP 1/12 — Homebrew"

if ! command -v brew &>/dev/null; then
  info "Homebrew not found — installing now..."
  info "This may take a few minutes, please wait..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || fail "Homebrew installation failed"

  info "Adding Homebrew to PATH..."
  if [[ $(uname -m) == "arm64" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    info "Apple Silicon detected → /opt/homebrew"
  else
    eval "$(/usr/local/bin/brew shellenv)"
    info "Intel Mac detected → /usr/local"
  fi
  success "Homebrew installed successfully"
else
  BREW_VERSION=$(brew --version | head -1)
  success "Homebrew already installed — $BREW_VERSION"
  info "Updating Homebrew..."
  brew update 2>&1 | tail -1
  success "Homebrew updated"
fi


# ─────────────────────────────────────────
# 2. BREWFILE
# ─────────────────────────────────────────
log "STEP 2/12 — Installing packages from Brewfile"
info "This is the longest step — installing all apps and tools"
info "Brewfile location: $SCRIPT_DIR/Brewfile"
echo ""

BREW_COUNT=$(grep -c "^brew " "$SCRIPT_DIR/Brewfile" 2>/dev/null || echo "?")
CASK_COUNT=$(grep -c "^cask " "$SCRIPT_DIR/Brewfile" 2>/dev/null || echo "?")
MAS_COUNT=$(grep -c "^mas " "$SCRIPT_DIR/Brewfile" 2>/dev/null || echo "?")
info "Found: ${BREW_COUNT} brew packages, ${CASK_COUNT} casks, ${MAS_COUNT} Mac App Store apps"
echo ""

if brew bundle --file="$SCRIPT_DIR/Brewfile"; then
  success "All Brewfile packages installed"
else
  fail "Some Brewfile packages failed — check output above"
fi


# ─────────────────────────────────────────
# 3. SYMLINK DOTFILES
# ─────────────────────────────────────────
log "STEP 3/12 — Symlinking dotfiles"

symlink() {
  local src=$1
  local dst=$2
  local label=${3:-$dst}

  mkdir -p "$(dirname "$dst")"

  if [ -f "$dst" ] && [ ! -L "$dst" ]; then
    warn "Existing file found at $dst — backing up to $dst.bak"
    mv "$dst" "$dst.bak"
  fi

  if ln -sf "$src" "$dst" 2>/dev/null; then
    success "Linked: $label"
  else
    fail "Failed to link: $label"
  fi
}

symlink "$SCRIPT_DIR/.zshrc"              ~/.zshrc                 ".zshrc"
symlink "$SCRIPT_DIR/.gitconfig"          ~/.gitconfig             ".gitconfig"
symlink "$SCRIPT_DIR/Brewfile"            ~/.Brewfile              "Brewfile"
symlink "$SCRIPT_DIR/starship.toml"       ~/.config/starship.toml  "starship.toml"
symlink "$SCRIPT_DIR/vscode/settings.json" \
  "$HOME/Library/Application Support/Code/User/settings.json" "VS Code settings.json"


# ─────────────────────────────────────────
# 4. SSH KEY SETUP
# ─────────────────────────────────────────
log "STEP 4/12 — SSH Key"

SSH_KEY="$HOME/.ssh/id_ed25519"

if [ -f "$SSH_KEY" ]; then
  success "SSH key already exists at $SSH_KEY"
else
  info "No SSH key found — generating one..."
  mkdir -p ~/.ssh && chmod 700 ~/.ssh

  GIT_EMAIL=$(git config --global user.email 2>/dev/null)
  if [ -z "$GIT_EMAIL" ]; then
    GIT_EMAIL="your@email.com"
    warn "No git email found — using placeholder, update .gitconfig manually"
  fi

  ssh-keygen -t ed25519 -C "$GIT_EMAIL" -f "$SSH_KEY" -N ""
  success "SSH key generated: $SSH_KEY"
fi

# Add to ssh-agent
eval "$(ssh-agent -s)" &>/dev/null
ssh-add "$SSH_KEY" 2>/dev/null
success "SSH key added to agent"

# Test GitHub connection
info "Testing GitHub SSH connection..."
SSH_TEST=$(ssh -o StrictHostKeyChecking=accept-new -T git@github.com 2>&1 || true)

if echo "$SSH_TEST" | grep -q "successfully authenticated"; then
  success "GitHub SSH connection working"
  GITHUB_SSH=true
else
  warn "GitHub SSH not yet authorized"
  echo ""
  echo -e "  ${BOLD}Add this public key to GitHub:${NC}"
  echo -e "  ${CYAN}→ github.com → Settings → SSH and GPG keys → New SSH key${NC}"
  echo ""
  echo "  $(cat $SSH_KEY.pub)"
  echo ""
  echo -e "  ${YELLOW}Press Enter after adding the key to GitHub to continue...${NC}"
  read -r

  SSH_RETEST=$(ssh -o StrictHostKeyChecking=accept-new -T git@github.com 2>&1 || true)
  if echo "$SSH_RETEST" | grep -q "successfully authenticated"; then
    success "GitHub SSH connection verified"
    GITHUB_SSH=true
  else
    warn "SSH still not verified — using HTTPS for all git cloning"
    GITHUB_SSH=false
  fi
fi


# ─────────────────────────────────────────
# 5. OH MY ZSH
# ─────────────────────────────────────────
log "STEP 5/12 — Oh My Zsh"

if [ -d "$HOME/.oh-my-zsh" ]; then
  warn "Oh My Zsh already installed — skipping"
  info "To update: omz update"
else
  info "Installing Oh My Zsh (unattended)..."
  # Note: OMZ installer may overwrite .zshrc — symlink is re-applied after
  if sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended; then
    success "Oh My Zsh installed"
    # OMZ installer overwrites ~/.zshrc — re-apply our symlink
    info "Re-applying .zshrc symlink (OMZ overwrites it)..."
    ln -sf "$SCRIPT_DIR/.zshrc" ~/.zshrc
    success "Symlink restored"
  else
    fail "Oh My Zsh installation failed"
  fi
fi

info "Installing Oh My Zsh plugins..."
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

clone_plugin() {
  local name=$1
  local repo=$2   # always HTTPS — no SSH needed
  local dir=$3
  if [ -d "$dir" ]; then
    warn "Plugin already exists: $name — skipping"
  else
    info "Cloning $name..."
    if git clone --depth=1 "$repo" "$dir" 2>/dev/null; then
      success "Plugin installed: $name"
    else
      fail "Failed to install plugin: $name"
    fi
  fi
}

clone_plugin "zsh-autosuggestions" \
  "https://github.com/zsh-users/zsh-autosuggestions.git" \
  "$ZSH_CUSTOM/plugins/zsh-autosuggestions"

clone_plugin "zsh-syntax-highlighting" \
  "https://github.com/zsh-users/zsh-syntax-highlighting.git" \
  "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

clone_plugin "zsh-completions" \
  "https://github.com/zsh-users/zsh-completions.git" \
  "$ZSH_CUSTOM/plugins/zsh-completions"


# ─────────────────────────────────────────
# 6. ASDF SETUP
# ─────────────────────────────────────────
log "STEP 6/12 — asdf version manager"

if [[ $(uname -m) == "arm64" ]]; then
  ASDF_PATH="/opt/homebrew/opt/asdf/libexec/asdf.sh"
else
  ASDF_PATH="/usr/local/opt/asdf/libexec/asdf.sh"
fi

if [ -f "$ASDF_PATH" ]; then
  . "$ASDF_PATH"
  ASDF_VERSION=$(asdf version)
  success "asdf loaded — $ASDF_VERSION"
else
  fail "asdf not found at $ASDF_PATH — was it installed via Brewfile?"
fi


# ─────────────────────────────────────────
# 7. ASDF PLUGINS
# ─────────────────────────────────────────
log "STEP 7/12 — asdf plugins"
info "Using explicit HTTPS URLs — no SSH required"

install_plugin() {
  local plugin=$1
  local https_url=$2
  if asdf plugin list 2>/dev/null | grep -q "^$plugin$"; then
    warn "Plugin already added: $plugin"
  else
    info "Adding plugin: $plugin..."
    if asdf plugin add "$plugin" "$https_url" 2>/dev/null; then
      success "Plugin added: $plugin"
    else
      fail "Failed to add plugin: $plugin"
    fi
  fi
}

install_plugin nodejs  "https://github.com/asdf-vm/asdf-nodejs.git"
install_plugin python  "https://github.com/danhper/asdf-python.git"
install_plugin ruby    "https://github.com/asdf-vm/asdf-ruby.git"
install_plugin java    "https://github.com/halcyon/asdf-java.git"
install_plugin golang  "https://github.com/asdf-community/asdf-golang.git"
install_plugin rust    "https://github.com/asdf-community/asdf-rust.git"
install_plugin elixir  "https://github.com/asdf-vm/asdf-elixir.git"
install_plugin erlang  "https://github.com/asdf-vm/asdf-erlang.git"
install_plugin uv      "https://github.com/asdf-community/asdf-uv.git"


# ─────────────────────────────────────────
# 8. ASDF RUNTIMES
# ─────────────────────────────────────────
install_and_set_global() {
  local lang=$1
  local version=$2

  info "[$lang] Resolving latest version..."

  # Resolve 'latest' or 'latest:filter' to actual version number
  # asdf global does not accept 'latest' — needs real version string
  local resolved
  if [[ "$version" == "latest" ]]; then
    # Plain latest — no filter
    resolved=$(asdf latest "$lang" 2>/dev/null)
  elif [[ "$version" == latest:* ]]; then
    # latest:filter e.g. latest:temurin-21
    local filter="${version#latest:}"
    resolved=$(asdf latest "$lang" "$filter" 2>/dev/null)
  else
    # Already a real version string — use as-is
    resolved="$version"
  fi

  if [ -z "$resolved" ]; then
    fail "[$lang] Could not resolve version from '$version'"
    return
  fi

  info "[$lang] Resolved version: $resolved"

  # Install if not already installed
  if asdf list "$lang" 2>/dev/null | grep -q "$resolved"; then
    warn "[$lang] $resolved already installed — skipping install"
  else
    info "[$lang] Installing $resolved (compiling from source)..."
    if asdf install "$lang" "$resolved"; then
      success "[$lang] $resolved installed"
    else
      fail "[$lang] Failed to install $resolved"
      return
    fi
  fi

  # Set as global using resolved version
  # asdf v0.16+ changed syntax: writes version to ~/.tool-versions directly
  # Try new way first, fall back to old way
  if asdf set --home "$lang" "$resolved" 2>/dev/null; then
    success "[$lang] global → $resolved"
  elif asdf global "$lang" "$resolved" 2>/dev/null; then
    success "[$lang] global → $resolved"
  else
    # Final fallback: write directly to ~/.tool-versions
    if grep -q "^$lang " ~/.tool-versions 2>/dev/null; then
      sed -i '' "s/^$lang .*/$lang $resolved/" ~/.tool-versions
    else
      echo "$lang $resolved" >> ~/.tool-versions
    fi
    success "[$lang] global → $resolved (via ~/.tool-versions)"
  fi
}


# ─────────────────────────────────────────
# 8+9. INSTALL RUNTIMES & SET GLOBAL
# ─────────────────────────────────────────
log "STEP 8/12 — Installing runtimes and setting global versions"
info "Each language compiles from source — this will take a while"
info "You will see build output scrolling — that is normal!"
echo ""

install_and_set_global nodejs   latest
install_and_set_global python   latest
install_and_set_global ruby     latest
install_and_set_global java     "latest:temurin-21"
install_and_set_global golang   latest
install_and_set_global rust     latest

install_and_set_global uv       latest

# Erlang MUST be installed before Elixir
# Elixir versions are tied to OTP (Erlang) major version
install_and_set_global erlang latest

# Now detect the INSTALLED Erlang version (not just latest)
# and use it to pick the correct Elixir OTP variant
INSTALLED_ERLANG=$(asdf list erlang 2>/dev/null | grep -v "No versions" | tail -1 | tr -d ' *')
if [ -z "$INSTALLED_ERLANG" ]; then
  warn "[elixir] Could not detect installed Erlang — trying latest elixir anyway"
  ELIXIR_VERSION=$(asdf latest elixir 2>/dev/null)
else
  OTP_MAJOR=$(echo "$INSTALLED_ERLANG" | cut -d. -f1)
  info "[elixir] Detected installed Erlang: $INSTALLED_ERLANG (OTP $OTP_MAJOR)"
  # Find elixir version matching this OTP major
  ELIXIR_VERSION=$(asdf latest elixir "otp-${OTP_MAJOR}" 2>/dev/null)
  if [ -z "$ELIXIR_VERSION" ]; then
    ELIXIR_VERSION=$(asdf latest elixir "$OTP_MAJOR" 2>/dev/null)
  fi
  if [ -z "$ELIXIR_VERSION" ]; then
    warn "[elixir] No OTP-matched version found — using plain latest"
    ELIXIR_VERSION=$(asdf latest elixir 2>/dev/null)
  fi
fi

info "[elixir] Installing version: $ELIXIR_VERSION"
install_and_set_global elixir "$ELIXIR_VERSION"

info "Reshimming asdf (rebuilding PATH shims)..."
asdf reshim
success "asdf reshim complete"


# ─────────────────────────────────────────
# UV TOOLS
# ─────────────────────────────────────────
log "STEP 8b/12 — uv tools"

install_uv_tool() {
  local tool=$1
  if uv tool list 2>/dev/null | grep -q "^$tool "; then
    warn "uv tool already installed: $tool — skipping"
  else
    info "Installing uv tool: $tool..."
    if uv tool install "$tool"; then
      success "Installed: $tool"
    else
      fail "Failed to install uv tool: $tool"
    fi
  fi
}

install_uv_tool pre-commit


# ─────────────────────────────────────────
# 10. PODMAN
# ─────────────────────────────────────────
log "STEP 9/12 — Podman"

if ! command -v podman &>/dev/null; then
  fail "Podman not found — check Brewfile installation"
else
  PODMAN_VERSION=$(podman --version)
  info "Found: $PODMAN_VERSION"

  if podman machine list 2>/dev/null | grep -q "Currently running"; then
    warn "Podman machine already running — skipping"
  elif podman machine list 2>/dev/null | grep -q "podman-machine-default"; then
    info "Existing Podman machine found — starting it..."
    podman machine start && success "Podman machine started" || fail "Failed to start Podman machine"
  else
    info "Initializing new Podman machine..."
    podman machine init && success "Podman machine initialized" || fail "Failed to init Podman machine"
    info "Starting Podman machine..."
    podman machine start && success "Podman machine started" || fail "Failed to start Podman machine"
  fi

  info "Verifying Podman..."
  if podman info &>/dev/null; then
    success "Podman is working correctly"
  else
    warn "Podman verification failed — try 'podman machine start' manually"
  fi
fi


# ─────────────────────────────────────────
# 11. VSCODE EXTENSIONS
# ─────────────────────────────────────────
log "STEP 10/12 — VS Code extensions"

if ! command -v code &>/dev/null; then
  warn "VS Code CLI (code) not found"
  info "Open VS Code → Cmd+Shift+P → 'Shell Command: Install code in PATH'"
else
  CODE_VERSION=$(code --version | head -1)
  info "Found VS Code: $CODE_VERSION"
  echo ""

  EXTENSIONS_FILE="$SCRIPT_DIR/vscode/extensions.txt"
  if [ ! -f "$EXTENSIONS_FILE" ]; then
    warn "Extensions file not found: $EXTENSIONS_FILE — skipping"
  else
    info "Reading extensions from vscode/extensions.txt"
    echo ""

    INSTALLED=0
    SKIPPED=0
    FAILED=0

    INSTALLED_EXTS=$(code --list-extensions 2>/dev/null | tr '[:upper:]' '[:lower:]')

    while IFS= read -r line; do
      # Skip blank lines and comments
      [[ -z "$line" || "$line" == \#* ]] && continue

      ext="$line"
      if echo "$INSTALLED_EXTS" | grep -qi "^${ext}$"; then
        warn "Already installed: $ext — skipping"
        ((SKIPPED++))
      else
        info "Installing: $ext..."
        if code --install-extension "$ext" &>/dev/null; then
          success "$ext"
          ((INSTALLED++))
        else
          warn "Failed: $ext"
          ((FAILED++))
        fi
      fi
    done < "$EXTENSIONS_FILE"

    echo ""
    success "VS Code: $INSTALLED installed, $SKIPPED skipped, $FAILED failed"
  fi
fi


# ─────────────────────────────────────────
# GPG SETUP
# ─────────────────────────────────────────
log "BONUS — GPG for Git commit signing"

if command -v gpg &>/dev/null; then
  GPG_VERSION=$(gpg --version | head -1)
  success "GPG available — $GPG_VERSION"

  if ! grep -q "GPG_TTY" "$SCRIPT_DIR/.zshrc" 2>/dev/null; then
    printf '\nexport GPG_TTY=$(tty)\n' >> "$SCRIPT_DIR/.zshrc"
    # Fix any accidental 'nexport' typo
    sed -i '' 's/nexport/export/g' "$SCRIPT_DIR/.zshrc"
    success "Added GPG_TTY to .zshrc"
  else
    warn "GPG_TTY already in .zshrc — skipping"
  fi

  info "To set up GPG signing for git commits:"
  info "  1. Run: gpg --full-generate-key"
  info "  2. Run: gpg --list-secret-keys --keyid-format=long"
  info "  3. Run: git config --global user.signingkey <YOUR_KEY_ID>"
  info "  4. Run: git config --global commit.gpgsign true"
  info "  5. Export to GitHub: gpg --armor --export <YOUR_KEY_ID>"
else
  warn "GPG not found — install via Brewfile (gpg-suite)"
fi


# ─────────────────────────────────────────
# APPLY SHELL CONFIG
# ─────────────────────────────────────────
log "Applying shell configuration..."
if source ~/.zshrc 2>/dev/null; then
  success "Shell config applied"
else
  warn "Could not auto-apply — run 'source ~/.zshrc' manually"
fi


# ─────────────────────────────────────────
# SUMMARY
# ─────────────────────────────────────────
divider
echo ""
echo -e "${BOLD}Setup Summary${NC}"
echo -e "  Time taken: $(elapsed) seconds"
echo ""

if [ ${#ERRORS[@]} -eq 0 ]; then
  echo -e "  ${GREEN}${BOLD}✓ All steps completed successfully!${NC}"
else
  echo -e "  ${YELLOW}${BOLD}! Completed with ${#ERRORS[@]} issue(s):${NC}"
  for err in "${ERRORS[@]}"; do
    echo -e "    ${RED}✗${NC} $err"
  done
fi

echo ""
echo -e "${BOLD}Next steps:${NC}"
echo -e "  ${CYAN}1.${NC} source ~/.zshrc"
echo -e "  ${CYAN}2.${NC} asdf current                     ${CYAN}# verify all runtimes${NC}"
echo -e "  ${CYAN}3.${NC} podman run hello-world            ${CYAN}# verify podman${NC}"
echo -e "  ${CYAN}4.${NC} gpg --full-generate-key           ${CYAN}# set up commit signing${NC}"
echo -e "  ${CYAN}5.${NC} Open VS Code → sign in to GitHub Copilot"
echo -e "  ${CYAN}6.${NC} Option+Space → 'Time Zones'       ${CYAN}# add IST and Germany clocks${NC}"
echo ""
