#!/usr/bin/env bash
set -euo pipefail

# ----------- Config ----------------------------------------
NODE_VERSION="node@latest"
GEMINI_NPM_PACKAGE="@google/gemini-cli"
CLAUDE_NPM_PACKAGE="@anthropic-ai/claude-code"
# -----------------------------------------------------------

# ===========================
# ----- Logging Helpers -----
# ===========================
log_info()    { echo -e "ℹ️  $1"; }
log_success() { echo -e "✅ $1"; }
log_error()   { echo -e "❌ $1" >&2; exit 1; }

# ============================
# ----- Bootstrap Checks -----
# ============================
ensure_mise_installed() {
  if ! command -v mise &>/dev/null; then
    log_error "mise is not installed. Install it from https://mise.jdx.dev"
  fi
}

ensure_node_installed() {
  if ! command -v npm &>/dev/null; then
    log_info "npm not found. Installing Node.js via mise..."
    mise use -g "$NODE_VERSION"
  fi

  if ! command -v npm &>/dev/null; then
    log_error "npm is still missing after installing node — something went wrong."
  fi

  log_success "Node.js and npm are available."
}

# ======================
# ----- Installers -----
# ======================
install_gemini_cli() {
  log_info "Installing Gemini CLI globally..."
  npm install -g "$GEMINI_NPM_PACKAGE"
  log_success "Gemini CLI installed globally."
}

install_claude_cli() {
  log_info "Installing Claude CLI globally..."
  npm install -g "$CLAUDE_NPM_PACKAGE"
  log_success "Claude CLI installed globally."
}

# ============================
# ----- Generic Verifier -----
# ============================
verify_install() {
  local tool="$1"
  local verify_command="${2:---version}"  # Use "--version" by default

  if command -v "$tool" &>/dev/null; then
    log_success "'$tool' is available in PATH"
    if ! "$tool" $verify_command; then
      echo "⚠️ '$tool' was found but '$verify_command' failed"
    fi
  else
    log_error "'$tool' not found after installation"
  fi
}

# ===========================
# ----- Main Entrypoint -----
# ===========================
main() {
  ensure_mise_installed
  ensure_node_installed

  install_gemini_cli
  verify_install "gemini" "--version"

  install_claude_cli
  verify_install "claude" "--version"
}

main "$@"
